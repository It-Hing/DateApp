# DateApp

01 프로젝트 소개

02 프로젝트 UI

03 프로젝트 결과


프로젝트(앱) 설명

기존에 출시된 소개팅 앱과 다른 위치기반 소개팅 앱
실제 출시를 통한 앱창업도전

사용 기술

SWIFT, autolayout을 통한 ui구성, push(백그라운드, 포그라운드)

Google Firebase – RealTime Database

Google CloudFlatForm(GoogleMap)

IAP(Consumable)

핵심 기능

회원가입/로그인

설정 / 푸시알림

지도 / 채팅(1대1채팅 기능 구현)

인앱 결제 


지도설명

- 가까운 사람끼리 클러스터를 형성하여 원으로 나타내며 원안에 사람수를 표시

- 다른 사람들과 멀리 떨어져 있는 사람은 마커를 이용해 표시

- 클러스터를 클릭하면 지도상단에 클러스터에 속한 유저 목록이 나타남 

- 유저 목록이나 마커를 클릭하면 유저 상세정보가 나타남

채팅설명

- 실시간 1대1 채팅 구현

- 채팅방안에 있으면 채팅알림 푸시를 받지 않도록 구현

- 채팅 내용을 날짜를 통해 구분해주고 채팅의 분단위까지 표시 – 카카오톡과 유사한 UI

- 채팅방 목록은 최신 채팅이 있는 채팅방이 상단으로 가도록 구현

유저 프로필 설명

- 사진을 등록/추가/변경시 관리자에게 알림이 가게되고 관리자의 승인이 난 후 사진등록이 되도록 구현

- 사진이 승인이 되지 않은 경우 미리 설정된 기본 이미지가 나타나도록 구현


설정 목록

- 푸시설정

  메세지알림, 대화요청알림, 대화방생성알림, 이벤트알림 중 원하는 알림만 수신설정 가능

- 지도설정

  내위치 공개 ON/OFF, 원하는 성별만 지도에서 보이도록 설정가능 

- 차단목록

  차단했던 사람들 목록을 볼 수 있고 차단해제 가능

- 로그아웃

  로그아웃을 하면 지도에서 보이지 않고 모든 알람 차단

- 계정탈퇴

  계정탈퇴를 하면 모든 회원 정보 삭제 및 Keychain을 이용하여 한달간 재가입 방지

- 차단

  차단을 하면 차단한 상대방과 서로 모든 정보를 볼 수 없게 실시간으로 처리 
  
회원가입 UI

<img src="https://user-images.githubusercontent.com/61533510/81061005-8ca29200-8f0e-11ea-8e11-8c5474120ef6.png"></img>
<img src="https://user-images.githubusercontent.com/61533510/81061011-90361900-8f0e-11ea-88c0-daad692c8509.png"></img>
<img src="https://user-images.githubusercontent.com/61533510/81061020-93310980-8f0e-11ea-93d2-297b6dc4e91f.png"></img>
<img src="https://user-images.githubusercontent.com/61533510/81061024-95936380-8f0e-11ea-9966-d24950d52852.png"></img>



<채팅리스트>          <관심표시리스트>           <상대방프로필화면>

<img src="https://user-images.githubusercontent.com/61533510/81061966-3898ad00-8f10-11ea-9d95-be47da99f62c.png"></img>
<img src="https://user-images.githubusercontent.com/61533510/81061978-3a627080-8f10-11ea-800b-8a4dfbf2f560.png"></img>
<img src="https://user-images.githubusercontent.com/61533510/81063130-3b949d00-8f12-11ea-97ad-a8995e506475.png" width="20%"></img>




