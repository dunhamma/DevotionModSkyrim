using System.Reflection;
using System.Text.Json;
using System.Text.Json.Serialization;
using Mutagen.Bethesda;
using Mutagen.Bethesda.Skyrim;

if (args.Contains("--introspect"))
{
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

        ExecuteReflectionMerge(sourcePath, generatedPath, outputPath, request, report);
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
        || family.Equals("PERK", StringComparison.OrdinalIgnoreCase)
        || family.Equals("QUST", StringComparison.OrdinalIgnoreCase)
        || family.Equals("vmad", StringComparison.OrdinalIgnoreCase)
        || family.Equals("formlist", StringComparison.OrdinalIgnoreCase);
}

static void ExecuteReflectionMerge(string sourcePath, string generatedPath, string outputPath, StructuredMergeRequest request, MergeReport report)
{
    var mod = SkyrimMod.CreateFromBinary(sourcePath, SkyrimRelease.SkyrimSE);
    var generated = SkyrimMod.CreateFromBinary(generatedPath, SkyrimRelease.SkyrimSE);

    foreach (var operation in request.Operations)
    {
        if (operation.CkSemanticsRequired || operation.MergePolicy?.RequiresCkFinalization == true)
        {
            report.Warnings.Add($"{operation.Id}: copied as binary record data, but CK finalization is still required by policy.");
        }

        var generatedRecord = FindRecordByEditorId(generated, operation.Target);
        if (generatedRecord is null)
        {
            report.Blockers.Add($"{operation.Id}: generated plugin does not contain target {operation.Target}.");
            continue;
        }

        var group = FindCompatibleGroup(mod, generatedRecord.GetType());
        if (group is null)
        {
            report.Blockers.Add($"{operation.Id}: source plugin has no compatible group for {generatedRecord.GetType().Name}.");
            continue;
        }

        var recordToSet = DeepCopyRecord(generatedRecord);
        var setUntyped = group.GetType()
            .GetMethods(BindingFlags.Instance | BindingFlags.Public)
            .FirstOrDefault(m => m.Name == "SetUntyped" && m.GetParameters().Length == 1);
        if (setUntyped is null)
        {
            report.Blockers.Add($"{operation.Id}: compatible group does not expose SetUntyped.");
            continue;
        }

        setUntyped.Invoke(group, [recordToSet]);
        report.MergedTargets.Add(operation.Target ?? operation.Id ?? generatedRecord.GetType().Name);
        report.RecordsMerged += 1;
    }

    if (report.Blockers.Count != 0)
    {
        return;
    }

    using var stream = File.Create(outputPath);
    mod.WriteToBinary(stream);
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

static object? FindCompatibleGroup(SkyrimMod mod, Type recordType)
{
    foreach (var group in EnumerateGroups(mod))
    {
        var containedType = group.GetType().GetProperty("ContainedRecordType")?.GetValue(group) as Type;
        if (containedType is not null && containedType.IsAssignableFrom(recordType))
        {
            return group;
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

static object DeepCopyRecord(object record)
{
    var method = record.GetType().GetMethod("DeepCopy", BindingFlags.Instance | BindingFlags.Public, Type.EmptyTypes);
    return method?.Invoke(record, []) ?? record;
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
