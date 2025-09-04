import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';


/// 축제 존재/참여 상태
enum FestivalGate {
  noFestival,          // 축제 문서가 없음 → 대기 불가
  alreadyParticipated, // finish/{email} 문서가 있음 → 이미 참여 → 대기 불가
  eligible,            // 축제 있음 + 미참여 → 대기 가능
}

/// 축제 상세 데이터
class FestivalData {
  final String id;
  final String? detail;
  final Timestamp? durationStart;
  final Timestamp? durationFinish;

  const FestivalData({
    required this.id,
    this.detail,
    this.durationStart,
    this.durationFinish,
  });

  String dateRangeText({String locale = 'ko_KR'}) {
    final fmt = DateFormat('yyyy년 M월 d일 (E) a h시 m분', locale);
    final st = durationStart?.toDate();
    final fi = durationFinish?.toDate();
    if (st == null && fi == null) return '기간 정보 없음';
    if (st != null && fi != null) return '${fmt.format(st)} ~ ${fmt.format(fi)}';
    if (st != null) return '${fmt.format(st)} ~';
    return '~ ${fmt.format(fi!)}';
  }
}

/// 최종 체크 결과
class FestivalCheckResult {
  final FestivalGate gate;
  final FestivalData? data;

  const FestivalCheckResult(this.gate, this.data);

  bool get canWait => gate == FestivalGate.eligible;
}

/// 축제 조회/참여여부 유틸
class FestivalService {
  static final _db = FirebaseFirestore.instance;

  /// ❶ 가장 단순: market/{marketId}/festival 에 문서가 하나라도 있으면
  /// 첫 문서를 읽어 반환(없으면 null).
  static Future<FestivalData?> fetchFirstFestival(String marketId) async {
    try {
      final snap = await _db
          .collection('market').doc(marketId)
          .collection('festival')
          .limit(1)
          .get();

      if (snap.docs.isEmpty) return null;

      final d = snap.docs.first;
      final data = d.data();
      return FestivalData(
        id: d.id,
        detail: data['detail'] as String?,
        durationStart: data['duration_st'] as Timestamp?,
        durationFinish: data['duration_fi'] as Timestamp?,
      );
    } on FirebaseException catch (e) {
      // 필요시 로깅
      // debugPrint('festival read error: ${e.code} ${e.message}');
      return null;
    }
  }

  /// ❷ (선택) 지금 진행 중인 축제만 찾고 싶을 때 사용하는 버전.
  static Future<FestivalData?> fetchOngoingFestival(String marketId) async {
    try {
      final now = Timestamp.now();
      final snap = await _db
          .collection('market').doc(marketId)
          .collection('festival')
          .where('duration_st', isLessThanOrEqualTo: now)
          .where('duration_fi', isGreaterThanOrEqualTo: now)
          .orderBy('duration_st', descending: true)
          .limit(1)
          .get();

      if (snap.docs.isEmpty) return null;

      final d = snap.docs.first;
      final data = d.data();
      return FestivalData(
        id: d.id,
        detail: data['detail'] as String?,
        durationStart: data['duration_st'] as Timestamp?,
        durationFinish: data['duration_fi'] as Timestamp?,
      );
    } on FirebaseException catch (_) {
      return null;
    }
  }

  /// ❸ 기존 바텀시트 로직 호환용:
  /// 축제 하나를 가져온 뒤 finish/{email} 문서 존재 여부로 게이트 판정.
  static Future<FestivalCheckResult> getFestivalStatusForUser({
    required String marketId,
    required String? email,
  }) async {
    final fes = await fetchFirstFestival(marketId);
    if (fes == null) {
      return const FestivalCheckResult(FestivalGate.noFestival, null);
    }

    // 참여여부 확인은 필요할 때만(이메일 없으면 미참여로 봄)
    if (email == null || email.isEmpty) {
      return FestivalCheckResult(FestivalGate.eligible, fes);
    }

    try {
      final finDoc = await _db
          .collection('market').doc(marketId)
          .collection('finish').doc(email)
          .get();

      if (finDoc.exists) {
        return FestivalCheckResult(FestivalGate.alreadyParticipated, fes);
      }
      return FestivalCheckResult(FestivalGate.eligible, fes);
    } on FirebaseException catch (_) {
      // 읽기 실패 시 보수적으로 '없음' 처리하거나 eligible 중 선택
      return FestivalCheckResult(FestivalGate.noFestival, null);
    }
  }
}
