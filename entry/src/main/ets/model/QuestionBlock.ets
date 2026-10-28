export enum QUESTION_TYPE {
  FIRST = 1,
  SECOND = 2,
  THIRD = 3
}

export class QuestionBlock {
  id: number = 0
  courseId: number = 0
  questionType: number = QUESTION_TYPE.FIRST
  title: string = ''
  aiAnswer: string = ''
  userReflection: string = ''
  status: number = 0
  createdAt: number = 0
}
