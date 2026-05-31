using System.Reflection;
using System.Text.Json;
using System.Text.Json.Serialization;
using Mutagen.Bethesda;
using Mutagen.Bethesda.Skyrim;

if (args.Contains("--introspect"))
{
    if (args.Contains("--constructors"))
    {
        var constructors = typeof(SkyrimMod)
            .GetConstructors(BindingFlags.Instance | BindingFlags.Public)
            .Select(m => new
            {
                Signature = m.ToString(),
                Parameters = m.GetParameters().Select(p => new { p.Name, Type = p.ParameterType.FullName, HasDefault = p.HasDefaultValue, Default = p.DefaultValue?.ToString() }).ToArray()
            })
            .OrderBy(m => m.Signature)
            .ToArray();
        Console.WriteLine(JsonSerializer.Serialize(constructors, JsonOptions()));
        return 0;
    }
    if (args.Contains("--modkey"))
    {
        var methods = typeof(Mutagen.Bethesda.Plugins.ModKey)
            .GetMethods(BindingFlags.Static | BindingFlags.Public)
            .Select(m => m.ToString())
            .OrderBy(m => m)
            .ToArray();
        Console.WriteLine(JsonSerializer.Serialize(methods, JsonOptions()));
        return 0;
    }
    if (args.Contains("--masterref"))
    {
        var masterRefType = typeof(Mutagen.Bethesda.Plugins.Records.MasterReference);
        var constructors = masterRefType
            .GetConstructors(BindingFlags.Instance | BindingFlags.Public)
            .Select(m => m.ToString())
            .OrderBy(m => m)
            .ToArray();
        var masterRefProperties = masterRefType
            .GetProperties(BindingFlags.Instance | BindingFlags.Public)
            .Select(p => new { p.Name, Type = p.PropertyType.FullName, CanWrite = p.CanWrite })
            .OrderBy(p => p.Name)
            .ToArray();
        Console.WriteLine(JsonSerializer.Serialize(new { constructors, properties = masterRefProperties }, JsonOptions()));
        return 0;
    }
    if (args.Contains("--header"))
    {
        var headerProperties = typeof(SkyrimModHeader)
            .GetProperties(BindingFlags.Instance | BindingFlags.Public)
            .Select(p => new { p.Name, Type = p.PropertyType.FullName, CanWrite = p.CanWrite })
            .OrderBy(p => p.Name)
            .ToArray();
        Console.WriteLine(JsonSerializer.Serialize(new
        {
            properties = headerProperties,
            flagNames = Enum.GetNames(typeof(SkyrimModHeader.HeaderFlag))
        }, JsonOptions()));
        return 0;
    }
    if (args.Contains("--groups"))
    {
        var group = typeof(SkyrimMod).GetProperty("Globals")!.PropertyType;
        var members = group
            .GetMembers(BindingFlags.Instance | BindingFlags.Public)
            .Where(m => m.MemberType is MemberTypes.Method or MemberTypes.Property)
            .Select(m => m.ToString())
            .OrderBy(m => m)
            .ToArray();
        Console.WriteLine(JsonSerializer.Serialize(members, JsonOptions()));
        return 0;
    }
    if (args.Contains("--static"))
    {
        var methods = typeof(SkyrimMod)
            .GetMethods(BindingFlags.Static | BindingFlags.Public)
            .Select(m => m.ToString())
            .OrderBy(m => m)
            .ToArray();
        Console.WriteLine(JsonSerializer.Serialize(methods, JsonOptions()));
        return 0;
    }

    var properties = typeof(SkyrimMod)
        .GetProperties(BindingFlags.Instance | BindingFlags.Public)
        .Select(p => new { p.Name, Type = p.PropertyType.FullName })
        .OrderBy(p => p.Name)
        .ToArray();
    Console.WriteLine(JsonSerializer.Serialize(properties, JsonOptions()));
    return 0;
}

if (args.Contains("--create-empty-plugin"))
{
    var pluginReport = new EmptyPluginReport
    {
        OutputPath = GetArg(args, "--output-path"),
        Master = GetArg(args, "--master") ?? "Skyrim.esm",
        Force = args.Contains("--force")
    };

    try
    {
        if (string.IsNullOrWhiteSpace(pluginReport.OutputPath))
        {
            throw new InvalidOperationException("--output-path is required.");
        }

        var fullOutputPath = Path.GetFullPath(pluginReport.OutputPath);
        pluginReport.OutputPath = fullOutputPath;
        if (File.Exists(fullOutputPath) && !pluginReport.Force)
        {
            throw new InvalidOperationException($"{fullOutputPath} already exists. Pass --force to replace it.");
        }

        Directory.CreateDirectory(Path.GetDirectoryName(fullOutputPath)!);
        WriteMinimalSkyrimPlugin(fullOutputPath, pluginReport.Master);

        var loaded = SkyrimMod.CreateFromBinary(fullOutputPath, SkyrimRelease.SkyrimSE);
        pluginReport.Exists = File.Exists(fullOutputPath);
        pluginReport.Length = new FileInfo(fullOutputPath).Length;
        pluginReport.RecordCount = CountRecords(loaded);
        pluginReport.IsMaster = ReadBoolProperty(loaded, "IsMaster");
        pluginReport.IsSmallMaster = ReadBoolProperty(loaded, "IsSmallMaster");
        pluginReport.MasterReferences = loaded.ModHeader.MasterReferences
            .Select(masterReference => masterReference.Master.FileName.String)
            .ToList();
        if (pluginReport.IsMaster == true)
        {
            pluginReport.Blockers.Add("Created plugin is marked as a master; expected writable ESP.");
        }
        if (pluginReport.IsSmallMaster == true)
        {
            pluginReport.Blockers.Add("Created plugin is marked as a small master; CK-active proof targets must be normal ESPs.");
        }
        if (!pluginReport.MasterReferences.Any(master => string.Equals(master, pluginReport.Master, StringComparison.OrdinalIgnoreCase)))
        {
            pluginReport.Blockers.Add($"Created plugin does not reference required master {pluginReport.Master}.");
        }
        pluginReport.Status = pluginReport.Blockers.Count == 0 ? "PASS" : "FAIL";
    }
    catch (Exception ex)
    {
        pluginReport.Status = "FAIL";
        pluginReport.Blockers.Add(ex.Message);
        pluginReport.Exception = ex.ToString();
    }

    Console.WriteLine(JsonSerializer.Serialize(pluginReport, JsonOptions()));
    return pluginReport.Status == "PASS" ? 0 : 1;
}

var requestPath = GetArg(args, "--request");
var sourcePath = GetArg(args, "--source-path");
var generatedPath = GetArg(args, "--generated-path");
var outputPath = GetArg(args, "--output-path");
var backupRoot = GetArg(args, "--backup-root");
var approved = args.Contains("--approved");
var dryRun = args.Contains("--dry-run");

var report = new MergeReport
{
    SourcePath = sourcePath,
    GeneratedPath = generatedPath,
    OutputPath = outputPath,
    DryRun = dryRun,
    Approved = approved
};

try
{
    if (string.IsNullOrWhiteSpace(requestPath)) throw new InvalidOperationException("--request is required.");
    if (string.IsNullOrWhiteSpace(sourcePath)) throw new InvalidOperationException("--source-path is required.");
    if (string.IsNullOrWhiteSpace(generatedPath)) throw new InvalidOperationException("--generated-path is required.");
    if (string.IsNullOrWhiteSpace(outputPath)) throw new InvalidOperationException("--output-path is required.");
    if (!approved) throw new InvalidOperationException("--approved is required for merge execution.");
    if (Path.GetFullPath(sourcePath).Equals(Path.GetFullPath(outputPath), StringComparison.OrdinalIgnoreCase))
    {
        throw new InvalidOperationException("--output-path must be a merge candidate path; refusing direct source plugin overwrite.");
    }

    var request = JsonSerializer.Deserialize<StructuredMergeRequest>(
        File.ReadAllText(requestPath),
        JsonOptions()) ?? throw new InvalidOperationException("Could not parse merge request.");

    report.RequestSchema = request.Schema;
    report.OperationCount = request.Operations.Count;

    ValidateRequest(request, report);
    if (report.Blockers.Count == 0 && !dryRun)
    {
        Directory.CreateDirectory(Path.GetDirectoryName(Path.GetFullPath(outputPath))!);
        if (!string.IsNullOrWhiteSpace(backupRoot))
        {
            Directory.CreateDirectory(backupRoot);
            var backupStamp = DateTimeOffset.Now.ToString("yyyyMMdd-HHmmss");
            var sourceBackupPath = Path.Combine(backupRoot, $"{Path.GetFileName(sourcePath)}.{backupStamp}.bak");
            var generatedBackupPath = Path.Combine(backupRoot, $"{Path.GetFileName(generatedPath)}.{backupStamp}.bak");
            File.Copy(sourcePath, sourceBackupPath, overwrite: false);
            File.Copy(generatedPath, generatedBackupPath, overwrite: false);
            report.BackupPath = sourceBackupPath;
            report.BackupPaths.Add(sourceBackupPath);
            report.BackupPaths.Add(generatedBackupPath);
        }

        ExecuteCandidateOverlayMerge(generatedPath, outputPath, request, report);
        if (report.Blockers.Count == 0)
        {
            WriteRollbackMetadata(request, report);
        }
    }

    report.Status = report.Blockers.Count == 0 ? "PASS" : "UNSAFE_BLOCKED";
}
catch (Exception ex)
{
    report.Status = "FAIL";
    report.Blockers.Add(ex.Message);
    report.Exception = ex.ToString();
}

Console.WriteLine(JsonSerializer.Serialize(report, JsonOptions()));
return report.Status == "PASS" ? 0 : 1;

static void ValidateRequest(StructuredMergeRequest request, MergeReport report)
{
    if (!string.Equals(request.Schema, "creation-authoring.structured-merge-request.v1", StringComparison.Ordinal))
    {
        report.Blockers.Add($"Unsupported request schema: {request.Schema}");
    }

    foreach (var op in request.Operations)
    {
        if (!string.Equals(op.OnConflict, "fail", StringComparison.Ordinal))
        {
            report.Blockers.Add($"{op.Id}: merge runner v1 only accepts onConflict=fail.");
        }
        if (op.CkSemanticsRequired || op.MergePolicy?.RequiresCkFinalization == true)
        {
            report.CkFinalizationRequired.Add(op.Id ?? op.Target ?? op.Kind ?? "operation");
        }
        if (!IsSupportedRecordFamily(op.RecordFamily))
        {
            report.Blockers.Add($"{op.Id}: record family {op.RecordFamily ?? "(missing)"} is not in the v1 structured merge safe surface.");
        }
    }
}

static bool IsSupportedRecordFamily(string? family)
{
    if (string.IsNullOrWhiteSpace(family)) return false;
    return family.Equals("ACTI", StringComparison.OrdinalIgnoreCase)
        || family.Equals("GLOB", StringComparison.OrdinalIgnoreCase)
        || family.Equals("KYWD", StringComparison.OrdinalIgnoreCase)
        || family.Equals("FLST", StringComparison.OrdinalIgnoreCase)
        || family.Equals("MGEF", StringComparison.OrdinalIgnoreCase)
        || family.Equals("NPC_", StringComparison.OrdinalIgnoreCase)
        || family.Equals("PACK", StringComparison.OrdinalIgnoreCase)
        || family.Equals("PERK", StringComparison.OrdinalIgnoreCase)
        || family.Equals("QUST", StringComparison.OrdinalIgnoreCase)
        || family.Equals("vmad", StringComparison.OrdinalIgnoreCase)
        || family.Equals("formlist", StringComparison.OrdinalIgnoreCase);
}

static void ExecuteCandidateOverlayMerge(string generatedPath, string outputPath, StructuredMergeRequest request, MergeReport report)
{
    var generated = SkyrimMod.CreateFromBinary(generatedPath, SkyrimRelease.SkyrimSE);

    foreach (var operation in request.Operations)
    {
        if (operation.CkSemanticsRequired || operation.MergePolicy?.RequiresCkFinalization == true)
        {
            report.Warnings.Add($"{operation.Id}: candidate overlay copied from generated proof, but CK finalization is still required by policy.");
        }

        var generatedRecord = FindRecordByEditorId(generated, operation.Target);
        if (generatedRecord is null)
        {
            report.Blockers.Add($"{operation.Id}: generated plugin does not contain target {operation.Target}.");
            continue;
        }

        report.MergedTargets.Add(operation.Target ?? operation.Id ?? generatedRecord.GetType().Name);
        report.RecordsMerged += 1;
    }

    if (report.Blockers.Count != 0)
    {
        return;
    }

    generated.ModHeader.Flags &= ~SkyrimModHeader.HeaderFlag.Master;
    generated.ModHeader.Flags &= ~SkyrimModHeader.HeaderFlag.Small;

    using var stream = File.Create(outputPath);
    generated.WriteToBinary(stream);
    report.TouchedFiles.Add(Path.GetFullPath(outputPath));
}

static object? FindRecordByEditorId(SkyrimMod mod, string? editorId)
{
    if (string.IsNullOrWhiteSpace(editorId)) return null;
    foreach (var group in EnumerateGroups(mod))
    {
        var records = group.GetType().GetProperty("Records")?.GetValue(group) as System.Collections.IEnumerable;
        if (records is null) continue;
        foreach (var record in records)
        {
            var recordEditorId = record.GetType().GetProperty("EditorID")?.GetValue(record) as string;
            if (string.Equals(recordEditorId, editorId, StringComparison.OrdinalIgnoreCase))
            {
                return record;
            }
        }
    }
    return null;
}

static IEnumerable<object> EnumerateGroups(SkyrimMod mod)
{
    foreach (var property in typeof(SkyrimMod).GetProperties(BindingFlags.Instance | BindingFlags.Public))
    {
        var typeName = property.PropertyType.FullName;
        if (typeName is null || !typeName.StartsWith("Mutagen.Bethesda.Skyrim.SkyrimGroup`1", StringComparison.Ordinal))
        {
            continue;
        }

        var group = property.GetValue(mod);
        if (group is not null)
        {
            yield return group;
        }
    }
}

static void WriteMinimalSkyrimPlugin(string outputPath, string master)
{
    using var body = new MemoryStream();
    using (var bodyWriter = new BinaryWriter(body, System.Text.Encoding.ASCII, leaveOpen: true))
    {
        WriteField(bodyWriter, "HEDR", fieldWriter =>
        {
            fieldWriter.Write(1.71f);
            fieldWriter.Write(0u);
            fieldWriter.Write(0u);
        });
        WriteStringField(bodyWriter, "MAST", master);
        WriteField(bodyWriter, "DATA", fieldWriter => fieldWriter.Write(0UL));
        WriteStringField(bodyWriter, "CNAM", "CKRA");
        WriteStringField(bodyWriter, "SNAM", "Creation fill spike v1 generated CK proof target.");
    }

    using var file = File.Create(outputPath);
    using var writer = new BinaryWriter(file, System.Text.Encoding.ASCII);
    writer.Write(System.Text.Encoding.ASCII.GetBytes("TES4"));
    writer.Write((uint)body.Length);
    writer.Write(0u);
    writer.Write(0u);
    writer.Write(0u);
    writer.Write((ushort)44);
    writer.Write((ushort)0);
    writer.Write(body.ToArray());
}

static void WriteStringField(BinaryWriter writer, string name, string value)
{
    WriteField(writer, name, fieldWriter =>
    {
        fieldWriter.Write(System.Text.Encoding.ASCII.GetBytes(value));
        fieldWriter.Write((byte)0);
    });
}

static void WriteField(BinaryWriter writer, string name, Action<BinaryWriter> writePayload)
{
    using var payload = new MemoryStream();
    using (var payloadWriter = new BinaryWriter(payload, System.Text.Encoding.ASCII, leaveOpen: true))
    {
        writePayload(payloadWriter);
    }
    writer.Write(System.Text.Encoding.ASCII.GetBytes(name));
    writer.Write((ushort)payload.Length);
    writer.Write(payload.ToArray());
}

static int CountRecords(SkyrimMod mod)
{
    var count = 0;
    foreach (var group in EnumerateGroups(mod))
    {
        var records = group.GetType().GetProperty("Records")?.GetValue(group) as System.Collections.IEnumerable;
        if (records is null) continue;
        foreach (var _ in records)
        {
            count += 1;
        }
    }
    return count;
}

static bool? ReadBoolProperty(object source, string propertyName)
{
    return source.GetType().GetProperty(propertyName)?.GetValue(source) as bool?;
}

static void WriteRollbackMetadata(StructuredMergeRequest request, MergeReport report)
{
    if (string.IsNullOrWhiteSpace(report.OutputPath))
    {
        return;
    }
    var metadataPath = $"{Path.GetFullPath(report.OutputPath)}.rollback.json";
    var metadata = new
    {
        schema = "creation-authoring.rollback-metadata.v1",
        createdAt = DateTimeOffset.Now,
        sourcePath = report.SourcePath,
        generatedPath = report.GeneratedPath,
        outputPath = report.OutputPath,
        backupPaths = report.BackupPaths,
        touchedFiles = report.TouchedFiles,
        mergedTargets = report.MergedTargets,
        request = new
        {
            request.Schema,
            request.SourcePlugin,
            request.GeneratedPlugin,
            request.PreserveFormIds,
            request.RemapPolicy,
            request.ConflictPolicy
        }
    };
    File.WriteAllText(metadataPath, JsonSerializer.Serialize(metadata, JsonOptions()));
    report.RollbackMetadataPath = metadataPath;
    report.TouchedFiles.Add(metadataPath);
}

static string? GetArg(string[] args, string name)
{
    var index = Array.IndexOf(args, name);
    if (index < 0 || index + 1 >= args.Length) return null;
    return args[index + 1];
}

static JsonSerializerOptions JsonOptions()
{
    return new JsonSerializerOptions
    {
        PropertyNamingPolicy = JsonNamingPolicy.CamelCase,
        WriteIndented = true,
        DefaultIgnoreCondition = JsonIgnoreCondition.WhenWritingNull,
        PropertyNameCaseInsensitive = true
    };
}

public sealed class StructuredMergeRequest
{
    public string? Schema { get; set; }
    public string? SourcePlugin { get; set; }
    public string? GeneratedPlugin { get; set; }
    public string? PreserveFormIds { get; set; }
    public string? RemapPolicy { get; set; }
    public string? ConflictPolicy { get; set; }
    public List<MergeOperation> Operations { get; set; } = [];
}

public sealed class MergeOperation
{
    public string? Id { get; set; }
    public string? Kind { get; set; }
    public string? Target { get; set; }
    public string? Mode { get; set; }
    public string? OnConflict { get; set; }
    public string? RecordFamily { get; set; }
    public bool CkSemanticsRequired { get; set; }
    public MergePolicy? MergePolicy { get; set; }
    public string? ReviewIntent { get; set; }
}

public sealed class MergePolicy
{
    public string? Promote { get; set; }
    public string? PreserveFormId { get; set; }
    public bool RequiresCkFinalization { get; set; }
    public bool AllowSourceMutation { get; set; }
}

public sealed class MergeReport
{
    public string Schema { get; set; } = "creation-authoring.merge-runner-report.v1";
    public string Status { get; set; } = "TODO";
    public string? RequestSchema { get; set; }
    public string? SourcePath { get; set; }
    public string? GeneratedPath { get; set; }
    public string? OutputPath { get; set; }
    public string? BackupPath { get; set; }
    public string? RollbackMetadataPath { get; set; }
    public bool DryRun { get; set; }
    public bool Approved { get; set; }
    public int OperationCount { get; set; }
    public int RecordsMerged { get; set; }
    public List<string> BackupPaths { get; set; } = [];
    public List<string> TouchedFiles { get; set; } = [];
    public List<string> MergedTargets { get; set; } = [];
    public List<string> CkFinalizationRequired { get; set; } = [];
    public List<string> Warnings { get; set; } = [];
    public List<string> Blockers { get; set; } = [];
    public string? Exception { get; set; }
}

public sealed class EmptyPluginReport
{
    public string Schema { get; set; } = "creation-authoring.empty-plugin-report.v1";
    public string Status { get; set; } = "TODO";
    public string? OutputPath { get; set; }
    public string Master { get; set; } = "Skyrim.esm";
    public bool Force { get; set; }
    public bool Exists { get; set; }
    public long Length { get; set; }
    public int RecordCount { get; set; }
    public bool? IsMaster { get; set; }
    public bool? IsSmallMaster { get; set; }
    public List<string> MasterReferences { get; set; } = [];
    public List<string> Blockers { get; set; } = [];
    public string? Exception { get; set; }
}
