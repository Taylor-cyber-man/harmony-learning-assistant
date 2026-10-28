import { preferences } from '@kit.ArkData'
import { common } from '@kit.AbilityKit'

const PREF_NAME = 'app_settings'

// 内存缓存，避免每次 API 调用都读磁盘
let cachedApiKey: string = ''

// 默认 Key 留空，避免密钥泄露；用户首次安装后在个人中心填写自己的 Key
const DEFAULT_API_KEY = ''
const DEFAULT_ENDPOINT = 'https://api.deepseek.com/v1/chat/completions'
const DEFAULT_MODEL = 'deepseek-chat'
const DEFAULT_ANTHROPIC_ENDPOINT = 'https://api.deepseek.com/anthropic/v1/messages'
const DEFAULT_ANTHROPIC_MODEL = 'deepseek-v4-flash'

// 内存缓存 Anthropic Key（与 Chat Key 相同，但独立缓存）
let cachedAnthropicApiKey: string = ''

export class AppConfig {
  private static context: common.UIAbilityContext | null = null

  static init(ctx: common.UIAbilityContext): void {
    AppConfig.context = ctx
  }

  static async getApiKey(): Promise<string> {
    if (cachedApiKey.length > 0) {
      return cachedApiKey
    }
    if (AppConfig.context === null) {
      return DEFAULT_API_KEY
    }
    try {
      const prefs = await preferences.getPreferences(AppConfig.context, PREF_NAME)
      const key: string = prefs.getSync('api_key', DEFAULT_API_KEY) as string
      if (key.length > 0) {
        cachedApiKey = key
        return key
      }
    } catch (e) {
      // preferences 读取失败，返回默认值
    }
    return DEFAULT_API_KEY
  }

  static async setApiKey(key: string): Promise<void> {
    cachedApiKey = key
    if (AppConfig.context === null) {
      return
    }
    try {
      const prefs = await preferences.getPreferences(AppConfig.context, PREF_NAME)
      prefs.putSync('api_key', key)
      prefs.flush()
    } catch (e) {
      // 持久化失败，至少内存中已更新
    }
  }

  static getEndpoint(): string {
    return DEFAULT_ENDPOINT
  }

  static getModel(): string {
    return DEFAULT_MODEL
  }

  static getAnthropicEndpoint(): string {
    return DEFAULT_ANTHROPIC_ENDPOINT
  }

  static getAnthropicModel(): string {
    return DEFAULT_ANTHROPIC_MODEL
  }
}
