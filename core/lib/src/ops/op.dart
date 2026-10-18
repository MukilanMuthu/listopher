// op = one change. app + server pass these around. never edited after made.
// all op classes live in this one file: dart `sealed` needs subclasses in same file.
// see docs/adr/0005-data-model.md.

/// One change + who made it + when. Body says what changed.
class Op {
  /// uuid, made on phone. lets phone create ops offline.
  final String id;

  /// space this op touches.
  final String spaceId;

  /// item this op touches. null for space ops (space.create, space.rename).
  final String? itemId;

  /// user who made change. blame comes from here.
  final String userId;

  /// phone clock when made. utc. shown to humans only, never used for ordering.
  final DateTime clientTime;

  /// order number from server. null = still in outbox, not synced yet.
  final int? serverSeq;

  /// what changed.
  final OpBody body;

  const Op({
    required this.id,
    required this.spaceId,
    required this.itemId,
    required this.userId,
    required this.clientTime,
    required this.serverSeq,
    required this.body,
  });
}

/// What changed. One subclass per op type. `sealed` → switch must cover all.
sealed class OpBody {
  const OpBody();
}

/// space.create — new space.
class SpaceCreate extends OpBody {
  final String name;

  /// true = this phone's private space, never synced or shared.
  final bool private;

  const SpaceCreate({required this.name, required this.private});
}

/// space.rename — new name for space.
/// ponytail: whole-op last-writer-wins. two renames at once → one lost. fine for names.
class SpaceRename extends OpBody {
  final String name;

  const SpaceRename({required this.name});
}

/// item.add — new item in space.
class ItemAdd extends OpBody {
  final String name;

  /// how much. decimal: 1.5 kg ok. null = not said.
  final double? quantity;

  /// free text: "kg", "L", "pack". any language. null = no unit ("soap 1").
  final String? unit;

  final String? note;

  /// who asked for it. can differ from op.userId ("mum asked, i typed").
  final String requestedBy;

  const ItemAdd({
    required this.name,
    required this.quantity,
    required this.unit,
    required this.note,
    required this.requestedBy,
  });
}

/// item.update — edit item.
/// sends full state, not diff: null field = field cleared.
/// ponytail: whole-op last-writer-wins, same limit as SpaceRename.
class ItemUpdate extends OpBody {
  final String name;
  final double? quantity;
  final String? unit;
  final String? note;

  const ItemUpdate({
    required this.name,
    required this.quantity,
    required this.unit,
    required this.note,
  });
}

/// item.check — ticked off. checker = op.userId = buyer.
class ItemCheck extends OpBody {
  const ItemCheck();
}

/// item.uncheck — tick removed. clears checker.
class ItemUncheck extends OpBody {
  const ItemUncheck();
}

/// item.delete — item gone. op stays in log for blame.
class ItemDelete extends OpBody {
  const ItemDelete();
}
