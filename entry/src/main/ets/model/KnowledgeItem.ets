export enum KNOWLEDGE_SOURCE {
  MANUAL = 0,
  UPLOAD = 1,
  AI = 2
}

export class KnowledgeItem {
  id: number = 0
  courseId: number = 0
  title: string = ''
  content: string = ''
  source: number = KNOWLEDGE_SOURCE.MANUAL
  createdAt: number = 0
}
