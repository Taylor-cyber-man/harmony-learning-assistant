export enum BLOOM_LEVEL {
  REMEMBER = 1,
  UNDERSTAND = 2,
  APPLY = 3,
  ANALYZE = 4,
  EVALUATE = 5,
  CREATE = 6
}

@Observed
export class TestItem {
  id: number = 0
  courseId: number = 0
  questionText: string = ''
  bloomLevel: number = BLOOM_LEVEL.REMEMBER
  studentAnswer: string = ''
  aiFeedback: string = ''
  isCorrect: number = 0
  createdAt: number = 0
}
