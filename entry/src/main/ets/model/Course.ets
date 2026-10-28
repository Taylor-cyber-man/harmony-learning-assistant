export enum COURSE_STATUS {
  CREATED = 0,
  ACTIVE = 1,
  COMPLETED = 2,
  ARCHIVED = 3
}

export class Course {
  id: number = 0
  name: string = ''
  keywords: string = ''
  status: number = COURSE_STATUS.CREATED
  progress: number = 0
  sortOrder: number = 0
  createdAt: number = 0
  updatedAt: number = 0
}
