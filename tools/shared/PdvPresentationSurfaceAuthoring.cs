using Mutagen.Bethesda;
using Mutagen.Bethesda.Plugins;
using Mutagen.Bethesda.Plugins.Records;
using Mutagen.Bethesda.Skyrim;
using Mutagen.Bethesda.Strings;
using Noggog;

public sealed record PdvPresentationSurfaceSpec(
    string EffectEditorId,
    string EffectName,
    string ScriptName,
    string SoundPropertyName,
    FormKey SoundCue,
    string DebugPropertyName,
    FormKey DebugGlobal,
    FormKey? HitShader = null);

public static class PdvPresentationSurfaceAuthoring
{
    public static void ApplyHitShader(MagicEffect effect, FormKey hitShader)
    {
        effect.Flags &= ~MagicEffect.Flag.NoHitEffect;
        effect.HitShader = hitShader.ToNullableLink<IEffectShaderGetter>();
    }

    public static MagicEffect EnsureHiddenSoundCueEffect(
        SkyrimMod mod,
        Dictionary<string, ISkyrimMajorRecordGetter> index,
        Func<FormKey> allocateFormKey,
        PdvPresentationSurfaceSpec spec)
    {
        var effect = EnsureMagicEffect(mod, index, allocateFormKey, spec.EffectEditorId);
        effect.EditorID = spec.EffectEditorId;
        effect.FormVersion = 44;
        effect.Name = Tx(spec.EffectName);
        effect.Description = Tx("");
        effect.BaseCost = 0.0f;
        effect.MagicSkill = ActorValue.None;
        effect.ResistValue = ActorValue.None;
        effect.SkillUsageMultiplier = 0.0f;
        effect.ScriptEffectAIScore = 0.0f;
        effect.ScriptEffectAIDelayTime = 0.0f;
        effect.Flags = MagicEffect.Flag.Recover
            | MagicEffect.Flag.NoDuration
            | MagicEffect.Flag.NoArea
            | MagicEffect.Flag.HideInUI
            | MagicEffect.Flag.NoHitEffect;
        effect.Archetype = new MagicEffectArchetype(MagicEffectArchetype.TypeEnum.Script)
        {
            ActorValue = ActorValue.None
        };
        effect.CastType = CastType.FireAndForget;
        effect.TargetType = TargetType.Self;
        WireMagicEffectScript(effect, spec.ScriptName, new ScriptProperty[]
        {
            ObjectProp(spec.SoundPropertyName, spec.SoundCue),
            ObjectProp(spec.DebugPropertyName, spec.DebugGlobal)
        });
        return effect;
    }

    public static void SetPrimaryAndPresentationEffects(
        Spell spell,
        FormKey primaryEffect,
        float primaryMagnitude,
        int primaryDuration,
        FormKey presentationEffect)
    {
        spell.Effects.Clear();
        spell.Effects.Add(new Effect
        {
            BaseEffect = primaryEffect.ToNullableLink<IMagicEffectGetter>(),
            Data = new EffectData { Magnitude = primaryMagnitude, Area = 0, Duration = primaryDuration },
            Conditions = []
        });
        spell.Effects.Add(new Effect
        {
            BaseEffect = presentationEffect.ToNullableLink<IMagicEffectGetter>(),
            Data = new EffectData { Magnitude = 0.0f, Area = 0, Duration = 0 },
            Conditions = []
        });
    }

    public static void CheckHiddenSoundCueEffect(
        MagicEffect effect,
        PdvPresentationSurfaceSpec spec,
        IList<string> errors,
        IList<string> actions)
    {
        if (effect.Archetype is not MagicEffectArchetype archetype || archetype.Type != MagicEffectArchetype.TypeEnum.Script)
        {
            errors.Add($"{spec.EffectEditorId}: expected Script archetype.");
        }
        if (effect.CastType != CastType.FireAndForget || effect.TargetType != TargetType.Self)
        {
            errors.Add($"{spec.EffectEditorId}: expected self FireAndForget magic effect.");
        }
        if (!effect.Flags.HasFlag(MagicEffect.Flag.HideInUI))
        {
            errors.Add($"{spec.EffectEditorId}: expected HideInUI flag.");
        }

        var script = effect.VirtualMachineAdapter?.Scripts.FirstOrDefault(candidate => string.Equals(candidate.Name, spec.ScriptName, StringComparison.OrdinalIgnoreCase));
        if (script is null)
        {
            errors.Add($"{spec.EffectEditorId}: missing {spec.ScriptName}.");
            return;
        }

        CheckObjectProperty(script, spec.SoundPropertyName, spec.SoundCue, spec.EffectEditorId, errors, actions);
        CheckObjectProperty(script, spec.DebugPropertyName, spec.DebugGlobal, spec.EffectEditorId, errors, actions);
    }

    private static MagicEffect EnsureMagicEffect(
        SkyrimMod mod,
        Dictionary<string, ISkyrimMajorRecordGetter> index,
        Func<FormKey> allocateFormKey,
        string editorId)
    {
        if (index.TryGetValue(editorId, out var existing))
        {
            if (existing is not MagicEffect typed)
            {
                throw new InvalidOperationException($"{editorId} exists as {existing.GetType().Name}, expected MagicEffect.");
            }

            return typed;
        }

        var created = new MagicEffect(allocateFormKey(), SkyrimRelease.SkyrimSE);
        mod.MagicEffects.Add(created);
        index[editorId] = created;
        return created;
    }

    private static void WireMagicEffectScript(MagicEffect effect, string scriptName, IEnumerable<ScriptProperty> properties)
    {
        effect.VirtualMachineAdapter ??= new VirtualMachineAdapter();
        effect.VirtualMachineAdapter.Version = 5;
        effect.VirtualMachineAdapter.ObjectFormat = 2;
        var script = EnsureScript(effect.VirtualMachineAdapter.Scripts, scriptName);
        UpsertProperties(script, properties);
    }

    private static ScriptEntry EnsureScript(IList<ScriptEntry> scripts, string scriptName)
    {
        var script = scripts.FirstOrDefault(candidate => string.Equals(candidate.Name, scriptName, StringComparison.OrdinalIgnoreCase));
        if (script is not null)
        {
            script.Name = scriptName;
            return script;
        }

        script = new ScriptEntry
        {
            Name = scriptName,
            Flags = ScriptEntry.Flag.Local
        };
        scripts.Add(script);
        return script;
    }

    private static void UpsertProperties(ScriptEntry script, IEnumerable<ScriptProperty> properties)
    {
        foreach (var property in properties)
        {
            while (script.Properties.FirstOrDefault(candidate => string.Equals(candidate.Name, property.Name, StringComparison.OrdinalIgnoreCase)) is { } existing)
            {
                script.Properties.Remove(existing);
            }

            script.Properties.Add(property);
        }
    }

    private static ScriptObjectProperty ObjectProp(string name, FormKey formKey)
    {
        return new ScriptObjectProperty
        {
            Name = name,
            Flags = ScriptProperty.Flag.Edited,
            Object = formKey.ToLink<ISkyrimMajorRecordGetter>(),
            Alias = -1
        };
    }

    private static void CheckObjectProperty(ScriptEntry script, string propertyName, FormKey expected, string ownerLabel, IList<string> errors, IList<string> actions)
    {
        var property = script.Properties.FirstOrDefault(candidate => string.Equals(candidate.Name, propertyName, StringComparison.OrdinalIgnoreCase));
        if (property is not ScriptObjectProperty objectProperty)
        {
            errors.Add($"{ownerLabel}.{propertyName}: missing or not an object property.");
            return;
        }

        if (!objectProperty.Object.FormKey.Equals(expected))
        {
            errors.Add($"{ownerLabel}.{propertyName}: actual={objectProperty.Object.FormKey} expected={expected}.");
            return;
        }

        actions.Add($"{ownerLabel}.{propertyName} -> {expected} [ok]");
    }

    private static TranslatedString Tx(string value) => new(Language.English, value);
}
