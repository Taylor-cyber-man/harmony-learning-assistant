import { TestItem } from '../model/TestItem'

export interface EvaluationResult {
  conceptScore: number
  criticalThinkingScore: number
  practiceScore: number
  correctCount: number
  totalCount: number
  gapList: string[]
  suggestions: string[]
}

export class Evaluator {

  evaluate(testItems: TestItem[]): EvaluationResult {
    let conceptCorrect = 0
    let conceptTotal = 0
    let criticalCorrect = 0
    let criticalTotal = 0
    let practiceCorrect = 0
    let practiceTotal = 0
    const gapList: string[] = []
    const suggestions: string[] = []

    for (const item of testItems) {
      if (item.bloomLevel <= 2) {
        conceptTotal++
        if (item.isCorrect === 1) {
          conceptCorrect++
        } else if (item.isCorrect === 2) {
          gapList.push(item.questionText.substring(0, 30) + '...')
        }
      } else if (item.bloomLevel <= 4) {
        criticalTotal++
        if (item.isCorrect === 1) {
          criticalCorrect++
        } else if (item.isCorrect === 2) {
          gapList.push(item.questionText.substring(0, 30) + '...')
        }
      } else {
        practiceTotal++
        if (item.isCorrect === 1) {
          practiceCorrect++
        } else if (item.isCorrect === 2) {
          gapList.push(item.questionText.substring(0, 30) + '...')
        }
      }
    }

    const conceptScore = conceptTotal > 0 ? Math.round((conceptCorrect / conceptTotal) * 100) : 0
    const criticalThinkingScore = criticalTotal > 0 ?
      Math.round((criticalCorrect / criticalTotal) * 100) : 0
    const practiceScore = practiceTotal > 0 ? Math.round((practiceCorrect / practiceTotal) * 100) : 0

    // 生成复习建议
    if (conceptScore < 60) {
      suggestions.push('建议重新学习AI基础概念章节，加强记忆和理解层面知识')
    }
    if (criticalThinkingScore < 60) {
      suggestions.push('建议重点复习RAG技术原理和MCP协议，提升分析和应用能力')
    }
    if (practiceScore < 60) {
      suggestions.push('建议多做场景设计练习，如设计Agent系统架构方案')
    }
    if (gapList.length > 3) {
      suggestions.push('存在较多认知漏洞，建议重新进行一轮三问学习')
    }

    return {
      conceptScore: conceptScore,
      criticalThinkingScore: criticalThinkingScore,
      practiceScore: practiceScore,
      correctCount: testItems.filter((t: TestItem) => t.isCorrect === 1).length,
      totalCount: testItems.length,
      gapList: gapList,
      suggestions: suggestions
    } as EvaluationResult
  }
}
