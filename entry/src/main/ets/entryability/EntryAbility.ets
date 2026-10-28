import { AbilityConstant, ConfigurationConstant, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import { initDatabase, getDbStore } from '../database/DatabaseHelper';
import { preferences } from '@kit.ArkData';
import { AppConfig } from '../config/AppConfig';

const DOMAIN = 0x0000;
const PREF_NAME = 'app_settings';

export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    AppConfig.init(this.context);
    this.applySavedColorMode();
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onCreate');
    // 同步等待 DB 初始化完成——所有页面依赖 DB，不等会导致全部查询失败
    initDatabase(this.context).then(() => {
      hilog.info(DOMAIN, 'testTag', 'Database initialized successfully');
    })
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onWindowStageCreate');
    // 确保 DB 就绪后才加载页面
    this.waitForDbThenLoad(windowStage)
  }

  private async waitForDbThenLoad(windowStage: window.WindowStage): Promise<void> {
    try {
      await getDbStore()
    } catch (e) {
      hilog.warn(DOMAIN, 'testTag', 'DB not ready yet, waiting...')
    }
    windowStage.loadContent('pages/Index', (err) => {
      if (err.code) {
        hilog.error(DOMAIN, 'testTag', 'Failed to load the content. Cause: %{public}s', JSON.stringify(err))
        return
      }
      hilog.info(DOMAIN, 'testTag', 'Succeeded in loading the content.')
    })
  }

  private async applySavedColorMode(): Promise<void> {
    try {
      const prefs = await preferences.getPreferences(this.context, PREF_NAME);
      const isDark: boolean = prefs.getSync('dark_mode', false) as boolean;
      if (isDark) {
        this.context.getApplicationContext().setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_DARK);
      } else {
        this.context.getApplicationContext().setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_LIGHT);
      }
    } catch (err) {
      try {
        this.context.getApplicationContext().setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET);
      } catch (e) {
        hilog.error(DOMAIN, 'testTag', 'Failed to set colorMode: %{public}s', JSON.stringify(e));
      }
    }
  }

  onDestroy(): void {
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onDestroy');
  }

  onWindowStageDestroy(): void {
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onWindowStageDestroy');
  }

  onForeground(): void {
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onForeground');
  }

  onBackground(): void {
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onBackground');
  }
}
