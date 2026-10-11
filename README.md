# FC축구특공대 온라인 운영진 앱

기존 v0.6 HTML 편성기를 iframe으로 재사용하고 Supabase Auth + 공용 데이터 저장 기능을 추가한 초기 온라인 전환판입니다. React로 재작성한 버전은 아닙니다. 클라우드 저장은 명시적으로 버튼을 눌러야 하며, 동시 편집 충돌 시 저장을 거부합니다. 기존 편성 알고리즘의 한계도 그대로 남아 있습니다.

## 준비
1. https://supabase.com 에서 프로젝트 생성.
2. SQL Editor에서 `schema.sql` 전체 실행.
3. Authentication > Providers에서 이메일 로그인 활성화. 공개 회원가입을 허용하지 말고, 운영진 계정을 Dashboard에서 초대/생성.
4. Authentication > Users에서 사용자 UUID 확인 후 `operators` 테이블에 등록. 예: `insert into public.operators(user_id,display_name) values ('UUID','운영진');`
5. Authentication > URL Configuration에서 Site URL을 Vercel 운영 URL로, Redirect URLs에 운영 URL 및 로컬 테스트 주소를 등록.
6. Project Connect에서 Project URL과 **publishable key** 복사. secret/service_role key는 절대 브라우저에 넣지 마세요.

## 로컬 실행
Node.js LTS 설치 후:
```
npm install
cp .env.example .env.local
# .env.local 수정
npm run dev
```

## GitHub / Vercel
1. 이 폴더의 파일들을 GitHub 비공개 저장소에 올립니다. `.env.local`은 업로드 금지.
2. Vercel > Add New Project > Import Git Repository.
3. Framework: Vite / Build: `npm run build` / Output: `dist`.
4. Environment Variables에 `VITE_SUPABASE_URL`, `VITE_SUPABASE_PUBLISHABLE_KEY` 입력.
5. Deploy 후 발급 URL을 Supabase Auth URL Configuration에 등록.
6. 운영진 이메일로 로그인하여 데이터 입력 후 **클라우드 저장** 버튼 클릭.

## 기존 v0.6 데이터 이전
기존 앱에서 JSON으로 운영 데이터를 내보내고, 온라인 앱의 편성기에서 JSON 불러오기를 실행한 뒤 상단 **클라우드 저장**을 누릅니다. 기존 브라우저 localStorage는 자동으로 서버에 업로드되지 않습니다.

## 주의
- 팀 공용 단일 상태(snapshot)를 버전 관리합니다. 여러 운영진의 변경 사항을 자동 병합하지 않습니다.
- 편성기는 기존 v0.6 로직 그대로이므로 2쿼터 배정 및 GK/심판 형평성의 완전한 최적화가 보장되지 않습니다.
- 운영 URL의 접근은 로그인으로 제한되며 DB는 operators allowlist + RLS로 보호합니다.
- 데이터 백업은 기존 편성기의 JSON 내보내기 기능을 이용하세요.
