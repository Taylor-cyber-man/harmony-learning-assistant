import { KnowledgeItem, KNOWLEDGE_SOURCE } from '../model/KnowledgeItem'
import { http } from '@kit.NetworkKit'
import { hilog } from '@kit.PerformanceAnalysisKit'
import { AppConfig } from '../config/AppConfig'

const TAG = 'AiEngine'
const DOMAIN = 0x0001

export class MentalModel {
  id: number = 0
  name: string = ''
  description: string = ''
  relations: string[] = []
  relationLabels: string[] = []
  children: string[] = []
  materialRef: string = ''
}

export class DisputePoint {
  id: number = 0
  title: string = ''
  proSide: string = ''
  conSide: string = ''
  proEvidence: string = ''
  conEvidence: string = ''
}

export interface TestQuestion {
  id: number
  question: string
  bloomLevel: number
  bloomName: string
  modelAnswer: string
}

// API 请求/响应对应的类
class ChatMessage {
  role: string = ''
  content: string = ''
}

class Choice {
  message: ChatMessage = new ChatMessage()
}

class ApiResponse {
  choices: Choice[] = []
}

export class AiEngine {

  // ========== 预置 HCIA-AI 核心知识点 ==========
  getPresetKnowledge(courseId: number, courseName: string): KnowledgeItem[] {
    const items: KnowledgeItem[] = []
    const now = Date.now()

    const knowledgeList: string[][] = [
      [courseName + ' - 基础概念', courseName + '是该领域的基础入门课程，涵盖核心概念、方法论和实际应用。掌握基础概念是后续深入学习的前提，建议从整体框架入手理解各知识点的关联。'],
      [courseName + ' - 核心方法论', '本课程的核心方法论包括：从理论到实践的渐进式学习路径、案例驱动的知识点讲解、以及强调动手实践的教学理念。建议学习者边学边练，通过实际项目巩固理论。'],
      [courseName + ' - 关键技术体系', '本课程涉及的关键技术包括主流框架和工具链。建议重点关注：1）基础原理的理解而非死记硬背；2）各技术之间的关联和演进关系；3）实际应用场景中的最佳实践。'],
      [courseName + ' - 经典模型与算法', '该领域的经典模型是其知识体系的核心支柱。理解模型的设计思想比记住公式更重要。建议从问题出发理解每个模型解决的核心痛点，再深入技术细节。'],
      [courseName + ' - 应用场景与实践', '理论的价值在于应用。本课程覆盖的应用场景包括多个行业的实际案例。建议学习时关注：业务需求如何转化为技术方案、不同方案的优劣对比、以及落地过程中的常见挑战。'],
      [courseName + ' - 工具链与平台', '掌握该领域的工具链和开发平台是生产力的关键。推荐从官方文档入手，逐步熟悉常用工具的配置、使用和最佳实践。注意保持工具版本与教学内容的兼容。'],
      [courseName + ' - 评估与优化', '没有评估就没有改进。本课程涉及多种评估指标和优化方法。核心思想：明确优化目标 → 选择合适指标 → 分析瓶颈 → 针对性改进 → 验证效果。这是一个持续迭代的过程。'],
      [courseName + ' - 前沿进展', '该领域发展迅速，课程涵盖最新的研究方向和产业趋势。建议在掌握基础后，关注顶级会议论文、开源社区动态和行业白皮书，保持知识的新鲜度。'],
      [courseName + ' - 常见误区与反面模式', '学习中最有价值的往往是知道"什么不要做"。本章总结的常见误区来自大量实践经验。建议：先尝试自己思考可能的问题，再对照教程验证，加深理解。'],
      [courseName + ' - 学习路径建议', '建议学习顺序：基础知识 → 核心方法 → 项目实践 → 前沿探索。每阶段设定可量化的目标（如完成一个小项目），保持学习节奏。遇到困难时回到基础概念重新梳理。']
    ]

    for (const k of knowledgeList) {
      const item = new KnowledgeItem()
      item.courseId = courseId
      item.title = k[0]
      item.content = k[1]
      item.source = KNOWLEDGE_SOURCE.AI
      item.createdAt = now
      items.push(item)
    }
    return items
  }

  // ========== 第一问：心智模型（预置降级数据）==========
  getMentalModels(): MentalModel[] {
    const models: MentalModel[] = []
    const m1 = new MentalModel()
        m1.id = 1; m1.name = '数据-算法-算力三角'; m1.description = 'AI系统的三个核心要素相互制约和促进。数据是燃料，算法是引擎，算力是加速器。三者的平衡决定了AI系统的性能上限。'; m1.relations = ['2']; m1.relationLabels = ['数据驱动']; m1.children = ['数据质量决定上限', '算法效率决定性价比', '算力瓶颈与突破']; m1.materialRef = '华为HCIA-AI - 基础概念'
    models.push(m1)
    const m2 = new MentalModel()
        m2.id = 2; m2.name = '神经网络分层抽象'; m2.description = '从感知机到Transformer，每一层神经网络提取不同粒度的特征。底层提取边缘/纹理，中层提取形状/部件，高层提取语义/概念。'; m2.relations = ['3']; m2.relationLabels = ['分层抽象']; m2.children = ['感知机与线性分类', '卷积层的局部感受野', 'Transformer的自注意力机制']; m2.materialRef = '华为HCIA-AI - 核心方法论'
    models.push(m2)
    const m3 = new MentalModel()
        m3.id = 3; m3.name = '预训练+微调范式'; m3.description = '先在海量数据上预训练基础模型（学习通用知识），再在特定任务上微调（学习领域知识）。这种范式大幅降低了AI应用的门槛。'; m3.relations = ['4']; m3.relationLabels = ['微调+检索']; m3.children = ['自监督学习原理', '领域适配微调策略', '参数高效微调(LoRA)']; m3.materialRef = '华为HCIA-AI - 关键技术体系'
    models.push(m3)
    const m4 = new MentalModel()
        m4.id = 4; m4.name = 'RAG检索增强模式'; m4.description = '将大模型的推理能力与外挂知识库的确定性结合。核心思想：不让模型"背"知识，而是让它"查"知识。这是解决幻觉问题的最有效方法之一。'; m4.relations = ['5']; m4.relationLabels = ['Agent工具']; m4.children = ['向量检索与语义相似度', '文档分块与索引策略', 'RAG与微调的取舍']; m4.materialRef = '华为HCIA-AI - 应用场景与实践'
    models.push(m4)
    const m5 = new MentalModel()
        m5.id = 5; m5.name = 'Agent LLM+P+M+T架构'; m5.description = '大模型是"大脑"（推理），Planning是"计划"（任务拆解），Memory是"记忆"（上下文和历史），Tool是"手脚"（调用外部工具）。这四者的组合使AI从"对话工具"进化到"自主行动系统"。'; m5.relations = ['1']; m5.relationLabels = ['算力基础']; m5.children = ['Planning任务拆解', 'Memory长短期记忆', 'Tool函数调用与MCP']; m5.materialRef = '华为HCIA-AI - 前沿进展'
    models.push(m5)
    return models
  }

  // ========== 第二问：技术争议（预置降级数据）==========
  getDisputePoints(): DisputePoint[] {
    const disputes: DisputePoint[] = []
    const d1 = new DisputePoint()
    d1.id = 1; d1.title = '闭源大模型 vs 开源大模型'; d1.proSide = '闭源（GPT-4）：性能更强，安全性更高，商业支持完善'; d1.conSide = '开源（DeepSeek/Llama）：自主可控，成本更低，可定制性强'; d1.proEvidence = 'GPT-4在MMLU等多基准测试中保持领先，企业级SLA保障'; d1.conEvidence = 'DeepSeek-V3在数学推理上达到GPT-4水平，开源促进技术民主化'
    disputes.push(d1)
    const d2 = new DisputePoint()
    d2.id = 2; d2.title = 'Fine-tuning微调 vs RAG检索增强'; d2.proSide = 'Fine-tuning：深度内化知识，推理速度更快，适合固定领域'; d2.conSide = 'RAG：知识实时更新，无需重新训练，幻觉可控'; d2.proEvidence = '医疗/法律等专业领域微调模型在特定任务上超越通用模型'; d2.conEvidence = 'RAG方案成本仅为微调的1/10，且支持知识库热更新'
    disputes.push(d2)
    const d3 = new DisputePoint()
    d3.id = 3; d3.title = '单Agent深度 vs 多Agent协作'; d3.proSide = '单Agent：架构简洁，延迟低，适合明确的任务边界'; d3.conSide = '多Agent：分工协作，各司其职，处理复杂工作流'; d3.proEvidence = 'Codex单Agent完成GitHub Copilot大部分编码任务'; d3.conEvidence = 'AutoGPT/AgentArts多Agent在长链条任务中完成率更高'
    disputes.push(d3)
    return disputes
  }

  // ========== 第三问：深度测试题 ==========
  getTestQuestions(): TestQuestion[] {
    const qs: TestQuestion[] = []
    qs.push({ id: 1, question: '请准确解释RAG的核心工作流程，并说明它与传统LLM回答方式的关键区别。', bloomLevel: 1, bloomName: '记忆', modelAnswer: 'RAG流程：用户提问→向量检索→召回Top-K文档→拼接为Context→LLM基于Context生成回答。与纯LLM的区别：纯LLM依赖训练时记忆，可能产生幻觉；RAG依赖外部检索的事实信息，回答可溯源。' } as TestQuestion)
    qs.push({ id: 2, question: '为什么大语言模型会产生"幻觉"（Hallucination）？用你自己的话解释其根本原因。', bloomLevel: 2, bloomName: '理解', modelAnswer: '根本原因：LLM本质是概率模型，基于训练数据的统计分布预测下一个token，而非基于真实世界知识的逻辑推理。当遇到训练数据中不充分或矛盾的信息时，模型会选择"最可能"的token，而不是"最正确"的token，从而产生幻觉。' } as TestQuestion)
    qs.push({ id: 3, question: '假设你在开发一个企业内部知识问答系统，员工询问"公司最新假期政策"，你应该选择Fine-tuning还是RAG方案？请说明理由。', bloomLevel: 3, bloomName: '应用', modelAnswer: '应该选择RAG。理由：1）政策会定期更新，RAG只需更新知识库，无需重新训练；2）RAG回答可溯源到具体政策文档；3）成本更低，不需要GPU训练资源。' } as TestQuestion)
    qs.push({ id: 4, question: '对比MCP协议和传统的RESTful API调用方式，分析它们在AI Agent场景下的各自优劣。', bloomLevel: 4, bloomName: '分析', modelAnswer: 'MCP优势：标准化接口、模型原生支持、减少适配代码。RESTful API优势：技术成熟、文档丰富、非AI场景也适用。' } as TestQuestion)
    qs.push({ id: 5, question: '评估DeepSeek选择开源的策略对AI行业生态的影响，从技术民主化和商业竞争两个角度分析。', bloomLevel: 5, bloomName: '评价', modelAnswer: '技术民主化正面：降低AI使用门槛，推动学术研究。商业竞争正面：打破OpenAI垄断，促进良性竞争。综合判断：利大于弊，开源策略推动AI普惠。' } as TestQuestion)
    qs.push({ id: 6, question: '设计一个结合DeepSeek+RAG+Agent的智能客服系统方案，需要描述系统架构和核心组件。', bloomLevel: 6, bloomName: '创造', modelAnswer: '架构设计：用户输入→Agent Planner分析意图→如需要知识查询，调用RAG检索知识库→如需要操作（退款/改签），调用Function Calling→Memory记录对话上下文→生成最终回复。' } as TestQuestion)
    qs.push({ id: 7, question: '解释Transformer中Self-Attention机制的工作原理，并说明为什么它比RNN更适合处理长文本。', bloomLevel: 1, bloomName: '记忆', modelAnswer: 'Self-Attention通过Query/Key/Value三矩阵计算每个词与其他所有词的关联权重。优于RNN的原因：RNN串行处理，长距离依赖会梯度消失；Self-Attention直接计算任意两词关系。' } as TestQuestion)
    qs.push({ id: 8, question: '用自己的话解释：为什么RAG方案中需要对文档进行"语义分块（Semantic Chunking）"而不是固定长度切分？', bloomLevel: 2, bloomName: '理解', modelAnswer: '固定长度切分可能在语义完整处断开（如把一个概念的解释切成两半），导致检索到的上下文不完整。语义分块保证每个chunk包含完整的语义单元，检索质量更高。' } as TestQuestion)
    qs.push({ id: 9, question: '给定一个医疗问诊场景，描述AI Agent如何处理"用户说头疼，需要判断是普通感冒还是偏头痛"这个任务，规划它的思考-行动链。', bloomLevel: 4, bloomName: '分析', modelAnswer: 'Thought：需要判断头痛类型→Action：调用症状问诊工具，获取更多信息→Observation：用户有畏光、单侧疼痛症状→Thought：可能是偏头痛→Action：查询医学知识库验证→Observation：匹配偏头痛特征→最终回复带条件的建议。' } as TestQuestion)
    qs.push({ id: 10, question: '你认为未来3年内，AI Agent技术会在哪些领域率先实现大规模商用？为什么？请给出判断标准和风险。', bloomLevel: 5, bloomName: '评价', modelAnswer: '最可能领域：1）客服（任务边界清晰，ROI可量化）；2）代码助手（开发者付费意愿强）；3）RPA+Agent（自动化流程改造）。判断标准：任务可拆解性、错误容错率、人工替代比。风险：安全责任归属、不可控行为、数据隐私。' } as TestQuestion)
    return qs
  }

  // ========== DeepSeek API 调用 ==========
  async callDeepSeekApi(systemPrompt: string, userPrompt: string): Promise<string> {
    hilog.info(DOMAIN, TAG, '=== API 请求开始 ===')
    hilog.info(DOMAIN, TAG, 'System Prompt: ' + systemPrompt.substring(0, 100))
    hilog.info(DOMAIN, TAG, 'User Prompt: ' + userPrompt.substring(0, 200))

    const apiKey = await AppConfig.getApiKey()
    const endpoint = AppConfig.getEndpoint()
    const model = AppConfig.getModel()

    const httpRequest = http.createHttp()
    const msg1 = new ChatMessage()
    msg1.role = 'system'
    msg1.content = systemPrompt
    const msg2 = new ChatMessage()
    msg2.role = 'user'
    msg2.content = userPrompt
    const messages: ChatMessage[] = [msg1, msg2]
    const body = JSON.stringify({
      model: model,
      messages: messages,
      temperature: 0.7
    })

    try {
      const response = await httpRequest.request(
        endpoint,
        {
          method: http.RequestMethod.POST,
          header: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer ' + apiKey
          },
          extraData: body
        }
      )
      const responseText: string = response.result as string
      hilog.info(DOMAIN, TAG, 'API 响应长度: ' + responseText.length)
      hilog.info(DOMAIN, TAG, 'API 响应内容(前500字): ' + responseText.substring(0, 500))
      const apiResp: ApiResponse = JSON.parse(responseText) as ApiResponse
      const content = apiResp.choices[0].message.content
      hilog.info(DOMAIN, TAG, '提取内容(前300字): ' + content.substring(0, 300))
      hilog.info(DOMAIN, TAG, '=== API 请求成功 ===')
      return content
    } catch (err) {
      hilog.error(DOMAIN, TAG, '=== API 请求失败 ===')
      const errMsg = 'API error: ' + JSON.stringify(err)
      hilog.error(DOMAIN, TAG, '错误信息: ' + errMsg)
      throw new Error(errMsg)
    }
  }

  async fetchMentalModels(knowledgeSummary: string): Promise<string> {
    const sysPrompt = '你是跨学科知识分析专家。基于用户提供的知识内容，提炼出该领域专家共享的5个核心心智模型（思维框架）。用中文回答。每个模型包含：名称name、一句话描述description、最核心的一个关联关系relations（数组，仅包含1个目标模型序号，选择该模型最直接的上下游依赖）、关联关系标签relationLabels（数组，与relations一一对应，1个简短标签2-4字）、子概念children（3个展开子主题）、关联资料标识materialRef（对应知识库中的资料标题）。仅返回纯JSON数组，不要markdown代码块包裹。格式: [{"name":"","description":"","relations":["1"],"relationLabels":["标签"],"children":[],"materialRef":""}]'
    return this.callDeepSeekApi(sysPrompt, knowledgeSummary)
  }

  async fetchDisputes(knowledgeSummary: string): Promise<string> {
    const sysPrompt = '你是跨学科学术分析专家。基于用户提供的知识内容，找出该领域专家存在根本性分歧的3个地方，给出正方观点+论据、反方观点+论据。用中文回答。仅返回纯JSON数组，不要markdown代码块包裹。格式: [{"title":"","proSide":"","conSide":"","proEvidence":"","conEvidence":""}]'
    return this.callDeepSeekApi(sysPrompt, knowledgeSummary)
  }

  async fetchTestQuestions(knowledgeSummary: string): Promise<TestQuestion[]> {
    const sysPrompt = '你是教育测评专家。基于知识库内容，生成10道测试题，覆盖布鲁姆认知层级（1记忆/2理解/3应用/4分析/5评价/6创造各层级都要覆盖）。JSON格式返回: [{"question":"题目","bloomLevel":数字,"bloomName":"层级名","modelAnswer":"参考答案"}]'
    const result = await this.callDeepSeekApi(sysPrompt, knowledgeSummary)
    const arr = JSON.parse(result) as Record<string, string>[]
    const qs: TestQuestion[] = []
    for (let i = 0; i < arr.length; i++) {
      qs.push({
        id: i + 1,
        question: arr[i]['question'] as string,
        bloomLevel: parseInt(arr[i]['bloomLevel'] as string),
        bloomName: arr[i]['bloomName'] as string,
        modelAnswer: arr[i]['modelAnswer'] as string
      } as TestQuestion)
    }
    return qs
  }

  async fetchKnowledgeItems(courseName: string): Promise<KnowledgeItem[]> {
    try {
      return await this.searchKnowledgeItems(courseName)
    } catch (e) {
      const errMsg: string = typeof e === 'object' && e !== null ?
        ((e as Record<string, Object>)['message'] as string) || JSON.stringify(e) :
        '' + e
      hilog.warn(DOMAIN, TAG, 'Anthropic 端点搜索失败，降级预置数据: ' + errMsg)
      return this.getPresetKnowledge(0, courseName)
    }
  }

  // ========== Anthropic 端点 + web_search 搜索 ==========
  async searchKnowledgeItems(courseName: string): Promise<KnowledgeItem[]> {
    hilog.info(DOMAIN, TAG, '=== Anthropic 端点搜索开始 ===')

    const apiKey = await AppConfig.getApiKey()
    const endpoint = AppConfig.getAnthropicEndpoint()
    const model = AppConfig.getAnthropicModel()

    const sysPrompt = '你是知识体系构建专家。使用 web_search 工具搜索与课程相关的最新、权威的互联网资料。' +
      '基于搜索结果，生成15条结构化知识点。每条包含标题、详细内容（200-300字，基于搜索到的真实信息）、来源网站名。' +
      '最后以纯JSON数组格式输出: [{"title":"","content":"","source":""}]'

    const userPrompt = '课程名称：' + courseName + '。请搜索该领域的最新权威资料并生成15条知识点。'

    // 构建请求体（用 Record 避免 untyped object literal）
    const tool: Record<string, string> = {
      'type': 'web_search_20260209',
      'name': 'web_search'
    }
    const tools: Record<string, string>[] = [tool]

    const sysMsg: Record<string, string> = {
      'role': 'system',
      'content': sysPrompt
    }
    const userMsg: Record<string, string> = {
      'role': 'user',
      'content': userPrompt
    }
    const messages: Record<string, string>[] = [sysMsg, userMsg]

    const requestBody: Record<string, Object> = {
      'model': model,
      'tools': tools,
      'messages': messages,
      'max_tokens': 8192
    }

    hilog.info(DOMAIN, TAG, 'Anthropic 端点: ' + endpoint)
    hilog.info(DOMAIN, TAG, '模型: ' + model)
    hilog.info(DOMAIN, TAG, 'API Key 前8位: ' + apiKey.substring(0, 8) + '...')

    const httpRequest = http.createHttp()
    const reqHeader: Record<string, string> = {
      'Content-Type': 'application/json',
      'x-api-key': apiKey
    }
    const bodyStr = JSON.stringify(requestBody)
    hilog.info(DOMAIN, TAG, '请求体长度: ' + bodyStr.length)

    const response = await httpRequest.request(
      endpoint,
      {
        method: http.RequestMethod.POST,
        header: reqHeader,
        extraData: bodyStr,
        expectDataType: http.HttpDataType.STRING,
        connectTimeout: 60000,
        readTimeout: 120000
      }
    )

    const respCode: number = response.responseCode
    hilog.info(DOMAIN, TAG, 'HTTP 响应码: ' + respCode)

    const responseText: string = response.result as string
    hilog.info(DOMAIN, TAG, 'Anthropic 响应长度: ' + responseText.length)

    if (respCode !== 200) {
      hilog.error(DOMAIN, TAG, 'HTTP 错误响应: ' + responseText.substring(0, 500))
      throw new Error('HTTP ' + respCode + ': ' + responseText.substring(0, 200))
    }

    hilog.info(DOMAIN, TAG, '响应前500字: ' + responseText.substring(0, 500))

    // 解析 Anthropic Messages 格式响应
    const anthropicResp = JSON.parse(responseText) as Record<string, Object>
    const content: Record<string, Object>[] = anthropicResp['content'] as Record<string, Object>[]

    // 提取搜索结果（来源 URL）
    const sources: Record<string, string> = {}
    for (let i = 0; i < content.length; i++) {
      const block = content[i]
      if (block['type'] === 'web_search_tool_result') {
        const results: Record<string, Object>[] = block['content'] as Record<string, Object>[]
        for (let j = 0; j < results.length; j++) {
          const r = results[j]
          const title: string = (r['title'] as string) || ''
          const url: string = (r['url'] as string) || ''
          if (title.length > 0) {
            sources[title] = url
          }
        }
      }
    }

    // 提取最后的 text 块（AI 总结 + JSON）
    let finalText = ''
    for (let i = content.length - 1; i >= 0; i--) {
      const block = content[i]
      if (block['type'] === 'text') {
        finalText = block['text'] as string
        break
      }
    }

    hilog.info(DOMAIN, TAG, '提取的 text 块(前500字): ' + finalText.substring(0, 500))
    hilog.info(DOMAIN, TAG, '搜索结果来源数量: ' + Object.keys(sources).length)

    // 从 finalText 中提取 JSON 数组（尝试多种模式）
    const items = this.extractKnowledgeFromText(finalText, sources)

    // 如果 JSON 提取失败，直接从搜索结果生成知识点
    if (items.length === 0 && finalText.length > 0) {
      hilog.info(DOMAIN, TAG, 'JSON提取失败，使用搜索源+AI文本回退方案')
      const fallbackItems = this.extractKnowledgeFromSearchResults(sources, finalText)
      for (let i = 0; i < fallbackItems.length; i++) {
        items.push(fallbackItems[i])
      }
    }

    if (items.length === 0) {
      throw new Error('未能从 Anthropic 响应中提取知识点')
    }

    hilog.info(DOMAIN, TAG, '=== Anthropic 搜索成功，生成 ' + items.length + ' 条知识点 ===')
    return items
  }

  private extractKnowledgeFromText(text: string, sources: Record<string, string>): KnowledgeItem[] {
    const items: KnowledgeItem[] = []
    const now = Date.now()

    // 尝试多种方式提取 JSON
    let jsonStr = ''

    // 方式1: ```json 代码块
    const fenceStart = text.indexOf('```json')
    if (fenceStart >= 0) {
      const afterFence = text.indexOf('\n', fenceStart)
      if (afterFence >= 0) {
        const fenceEnd = text.indexOf('```', afterFence)
        if (fenceEnd > afterFence) {
          jsonStr = text.substring(afterFence + 1, fenceEnd).trim()
        }
      }
    }

    // 方式2: 直接查找 [{ ... }]
    if (jsonStr.length === 0) {
      const jsonStart = text.indexOf('[{')
      if (jsonStart >= 0) {
        const jsonEnd = text.lastIndexOf('}]')
        if (jsonEnd > jsonStart) {
          jsonStr = text.substring(jsonStart, jsonEnd + 2)
        }
      }
    }

    // 方式3: 查找 [ { ... } ]（换行版）
    if (jsonStr.length === 0) {
      const jsonStart = text.indexOf('[\n')
      if (jsonStart >= 0) {
        const jsonEnd = text.lastIndexOf('\n]')
        if (jsonEnd > jsonStart) {
          jsonStr = text.substring(jsonStart, jsonEnd + 2)
        }
      }
    }

    if (jsonStr.length === 0) {
      hilog.info(DOMAIN, TAG, 'extractKnowledge: 未找到 JSON 结构')
      return items
    }

    hilog.info(DOMAIN, TAG, 'extractKnowledge: JSON 长度=' + jsonStr.length + ', 前200字=' + jsonStr.substring(0, 200))

    try {
      const arr = JSON.parse(jsonStr) as Record<string, string>[]
      for (let i = 0; i < arr.length; i++) {
        const item = new KnowledgeItem()
        item.title = arr[i]['title'] || ''
        item.content = arr[i]['content'] || ''

        // 拼接来源信息
        const sourceName = arr[i]['source'] || ''
        let sourceUrl = ''
        if (sourceName.length > 0) {
          // 在 sources 中模糊匹配
          const sourceKeys: string[] = Object.keys(sources)
          for (let k = 0; k < sourceKeys.length; k++) {
            if (sourceKeys[k].indexOf(sourceName) >= 0 || sourceName.indexOf(sourceKeys[k]) >= 0) {
              sourceUrl = sources[sourceKeys[k]]
              break
            }
          }
          if (sourceUrl.length > 0) {
            item.content = item.content + '\n\n来源: ' + sourceName + ' (' + sourceUrl + ')'
          } else {
            item.content = item.content + '\n\n来源: ' + sourceName
          }
        }
        item.source = KNOWLEDGE_SOURCE.AI
        item.createdAt = now
        items.push(item)
      }
    } catch (e) {
      hilog.error(DOMAIN, TAG, 'JSON 解析失败: ' + JSON.stringify(e))
    }
    return items
  }

  private extractKnowledgeFromSearchResults(sources: Record<string, string>,
    aiText: string): KnowledgeItem[] {
    const items: KnowledgeItem[] = []
    const now = Date.now()

    // 从搜索结果直接生成知识点（每条搜索结果是1个知识点）
    const keys: string[] = Object.keys(sources)
    const count = Math.min(keys.length, 15)
    for (let i = 0; i < count; i++) {
      const title = keys[i]
      const url = sources[title]
      const item = new KnowledgeItem()
      item.title = title
      // 使用 AI 文本摘要作为内容（取前300字）
      const contentSnippet = aiText.length > 300 ? aiText.substring(0, 300) + '...' : aiText
      item.content = contentSnippet + '\n\n原文链接: ' + url
      item.source = KNOWLEDGE_SOURCE.AI
      item.createdAt = now
      items.push(item)
    }

    // 如果搜索结果也不够，用 AI 文本额外补充几条
    if (items.length < 5 && aiText.length > 50) {
      const item = new KnowledgeItem()
      item.title = 'AI 综合分析'
      item.content = aiText.substring(0, 800)
      item.source = KNOWLEDGE_SOURCE.AI
      item.createdAt = now
      items.push(item)
    }

    return items
  }

  // ========== 综合评估：对整场学习+答题的全面评价 ==========
  async generateOverallSummary(courseName: string, qaLogJson: string,
    scores: Record<string, number>): Promise<string> {
    const qaData = JSON.parse(qaLogJson) as Record<string, Record<string, string>>
    const qaKeys = Object.keys(qaData)
    let qaText = ''
    for (let i = 0; i < qaKeys.length; i++) {
      const k = qaKeys[i]
      const q = qaData[k]
      qaText = qaText + 'Q' + (i + 1) + ': ' + q['question'] + '\n'
      qaText = qaText + '学生回答: ' + q['studentAnswer'] + '\n'
      qaText = qaText + 'AI反馈: ' + q['aiFeedback'] + '\n'
      qaText = qaText + '结果: ' + q['isCorrect'] + '\n\n'
    }

    const sysPrompt = '你是一位资深教育导师。请根据学生的答题表现，撰写一份全面的学习评价报告。' +
      '报告需包含：1）学习过程总体评价（学习态度、思维深度、知识掌握情况）' +
      '2）对各题回答的概括性总结（哪些领域表现好、哪些需要强化）' +
      '3）对题目的分析（题目覆盖了哪些认知层级和知识领域）' +
      '4）针对薄弱环节的具体改进建议。' +
      '用中文回答，分为四个部分，每部分有小标题。语言鼓励正面、专业。' +
      '格式: {"overallEvaluation":"整体评价","topicSummary":"题目概括性总结","strengths":"优势领域分析","improvements":"改进建议"}'

    const userPrompt = '课程: ' + courseName + '\n' +
      '概念理解得分: ' + scores['conceptScore'] + '\n' +
      '批判思维得分: ' + scores['criticalScore'] + '\n' +
      '实践迁移得分: ' + scores['practiceScore'] + '\n\n' +
      '以下是全部问答记录:\n' + qaText

    return this.callDeepSeekApi(sysPrompt, userPrompt)
  }

  async evaluateAnswer(question: string, studentAnswer: string): Promise<string> {
    const sysPrompt = '你是严格的学习导师。评价学生的回答：判断是否正确理解，指出认知漏洞，给出追问建议。用中文回答，JSON格式: {"isCorrect":true/false,"feedback":"评价内容"}'
    const userPrompt = '题目: ' + question + '\n学生回答: ' + studentAnswer
    return this.callDeepSeekApi(sysPrompt, userPrompt)
  }
}
