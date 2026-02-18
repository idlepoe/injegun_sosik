# BLoC 아키텍처 요약

출처: [bloclibrary.dev/ko/architecture](https://bloclibrary.dev/ko/architecture/)

---

## 3개 레이어

| 레이어 | 역할 |
|--------|------|
| **Data** | 데이터 조회/변경. Data Provider + Repository |
| **Business Logic** | UI 입력(Event) → 새 State 반환. Bloc |
| **Presentation** | Bloc State 기반 UI 렌더링 |

---

## Data Layer

- **Data Provider**: DB/네트워크 등에서 원시 데이터 제공 (CRUD).
- **Repository**: 하나 이상의 Data Provider를 감싸고, 데이터 변환 후 Business Logic에 전달.

## Business Logic Layer

- **Bloc**: Event 수신 → Repository 호출 → State emit.
- Bloc끼리 직접 구독하지 말 것. 연결이 필요하면 **Presentation에서 BlocListener**로 한 Bloc 변화 시 다른 Bloc에 Event 추가하거나, **Repository의 Stream**을 여러 Bloc이 공유하는 방식 사용.

## Presentation Layer

- Bloc에 Event 전달 (예: `AppStarted`).
- Bloc State에 따라 UI 구성 (`BlocBuilder` / `BlocListener` 등).
