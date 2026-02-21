dashboard

fcm service에선 payload에서 article 모델이 전체 전달되어 오는 것을 가정하여

push메시지 수신할 경우 모두 prefshared에 저장

isRead 읽음 상태 false로 하여 저장



appbar의 actions에 

notification icon button을 표시하고 해당 버튼을 누를 경우

notification list screen 으로 이동

해당 화면 appbar actions에 '모두 읽음' 텍스트 버튼이 표시

해당 버튼을 누를 경우 isRead true 처리

해당 화면에선 prefshared에 저장된 push메시지를 article_list_tile.dart의 형태로 표시



cog icon button을 표시하고 해당 버튼을 누를 경우 

setting screen으로 이동


setting screen

topic

"weekschedule" | "notice" | "job" | "livelihood" | "free"

각각 topic subscription을 하는 toggle 버튼

toggle 여부는 preferenceShared 에 저장하고 화면이 로드될때 toggle로 표시할 것.

toggle 처리는 fcm_service.dart 를 이용할 것.

섹션을 알림 설정이라고 표시하고 우측 토글을 표시하고 해당 토글을 off하면 모든 topic을 subscription 하거나 unsubscription 되도록 해줘.

