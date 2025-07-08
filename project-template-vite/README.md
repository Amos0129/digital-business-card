## Version : 1.0.4

### 開發環境
* gradle version: 8.7
* java version: 21
* node version: 20.12.2
* npm version: 11.2.0

### OSV-Scanner
1. build.gradle底下加上這段
    dependencyLocking {
       lockAllConfigurations()
       lockFile = file("$projectDir/lockfile/gradle.lockfile")
    }

2. 在專案根目錄執行 ./gradlew build --write-locks 建立 gradle.lockfile檔，檔案會產生在專案跟目錄的lockfile底下
3. 在專案根目錄執行 ./gradlew -q dependencies 會列出gralde第三方套件的dependency tree
4. 在專案react目錄執行 npm ls --prod --all 會列出npm production 第三方套件的dependency tree

osv-scanner即可檢查maven的依賴
osv-scanner -r X:\xxx\xxx\project-template-with-permission
PS. osv-scanner會吃.gitignore的樣子...

### Vite
***從CRA轉至為Vite，需將所有的page/config.js的 src:/xxx，改寫成comp: lazy(() => import('./xxx.js'))***

修改歷程如下：

1. 因CRA在有在webpack resolve設定使用modules設定，讓import的起始路徑為src，但Vite沒有這個設定，
故需在vite.config.mjs的resolve使用alias，分別設定在src底下的各個資料夾

2. Vite不像CRA有使用HMR，不支援Dynamic Import，故原本的./src/layout/router.js內lazy(()-import())寫法不能使用
    * 因此改為每個page的config.js加入名為comp的attribute，以靜態宣告的方式先行宣告後，於./src/layout/router.js匯入
   
3. 因沒使用Dynamic Import的關係(不確定)，將./src/layout/menu.js與./src/layout/top-menu.js的useNavigate的寫法，
改為使用NavigateComponent，用於避免在同一function裡，useRef(主要是useMemberInfo)與useNavigate有時間差的問題，會將頁面轉導到404