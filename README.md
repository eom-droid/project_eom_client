# 개인의 플랫폼화 ‘엄태호’

![Frame 1](https://github.com/user-attachments/assets/bbf6f18c-422c-43eb-a92b-0bd269d79839)


## 프로젝트 소개

- ‘엄태호’는 개인의 컨텐츠의 플랫폼화 및 퍼스널 마케팅을 할 수 있는 어플 입니다.
- 유저는 ‘엄태호’의 일기를 보고 좋아요를 누르거나 댓글을 작성할 수 있습니다.
- ‘엄태호’의 음악 취향을 확인할 수 있습니다.
- ‘엄태호’와의 실시간 채팅으로 더욱 깊은 유대감을 쌓을 수 있습니다.

## 팀원구성

엄태호

![KakaoTalk_Photo_2024-09-27-23-59-13 1](https://github.com/user-attachments/assets/84fdf715-28d9-481b-954a-5abbf507c0c5)



## 1. 개발 환경

- Client: Flutter
- Back-end: NodeJS, Express
- DB 및 기타: MongoDB, Redis
- 버전 및 이슈관리: Github
- 서비스 배포환경: AWS LightSail, Firebase
- 디자인: [Figma](https://www.figma.com/design/vrEIZvy0st4B1zhIqw79rV/Client?node-id=0-1&t=NyVhX4Z7BfJvuItF-1)

## 2. 프로젝트 구조 및 적용 기술

총 5개의 git repository를 생성하였으며 아래와 같은 인프라 구조를 가지고 있음
![스크린샷 2024-09-28 오전 3 27 58](https://github.com/user-attachments/assets/bc4f60ee-37f7-4176-9709-643d06bf928a)


- backend(NodeJS, Express)
    - Restful API 기본 CURD
    - AWS S3 이미지 업로드
    - JWT 활용 인증
    - Redis활용 JWT 관리
- chat_server(NodeJS)
    - SocketIO 활용 실시간 채팅서버
- client(Flutter)
    - go_router 활용 라우팅 설계
    - riverpod 활용 상태관리
- manger(Flutter)
    - client와 동일
- web(Vue)
    - firebase활용 배포

## 3. 신경쓴 부분

### 구조화된 코드 및 파일 시스템

- backend에서 api 버전별 파일시스템 분리(예: v1, v2 등)
- backend에서  routes → authCheck → middleware(input validation) → controllers → services → repositorys 순서의 로직
- client에서 riverpod provider를 활용한 상태관리 및 각 페이지별 컴포넌트화

### JWT활용 인증

- SNS 및 이메일 로그인 시 자체 JWT 발급 및 Redis 활용 관리(예: key:value = userId:Refresh JWT Token)
- Access Token 발급 시 Refresh Token 재발급과 Access Token 발급 시 Refresh Token 미일치 시 Refresh Token 폐기 절차 진행(RTR 방식)

### 앱스토어 배포

- 최종적으로 앱스토어 배포를 진행하지 못하였지만 아래와 같은 시도로 다양한 Reject 사유에 대한 학습이 가능하였음
![스크린샷 2024-09-28 오전 3 35 43](https://github.com/user-attachments/assets/97f28db7-9b1d-4669-ae6c-61edbf21aa57)
![스크린샷 2024-09-28 오전 3 50 44](https://github.com/user-attachments/assets/f4765159-b9ae-48ba-add1-7a8688cbbeda)


## 4. 페이지별 기능


https://github.com/user-attachments/assets/886ccdec-95da-4125-aed2-982c24fccb3e


## 5. 개선목표



### backend

- DTO, DAO, VO 개념 적용
- mySql 사용

### client & manager

- 다양한 기능 제공
    - map 기반 맛집, 보드타기 좋은곳 공유 등
- 비디오 스트리밍 라이브 기능


## 6. 후기

독학으로 기존 군에서의 기술(C++, C#, Delphi, JAVA 등)이 아닌 다른 언어로의 개발을 진행함에 언어 학습에 대한 장벽이 무너지는 계기가 되었다. 객체지향 프로그래밍에 대해 조금이나마 이해하는 계기가 되었으며, 재사용성을 높인 코드의 편리함을 학습하였다. 그리고 추후 다른 개발자와의 협업을 강조한 프로젝트의 필요성을 느꼈다.
