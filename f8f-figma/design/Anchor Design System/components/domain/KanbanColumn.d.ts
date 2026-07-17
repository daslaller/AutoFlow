/** Kanban board column shell (Backlog/To Do/In Progress/Review/Done) — wraps a stack of KanbanCard. @startingPoint section="Domain" subtitle="Board column with colored header + count" viewport="700x320" */
export interface KanbanColumnProps{ title:string; count:number; headerColor?:string; children?: React.ReactNode; }
export function KanbanColumn(props: KanbanColumnProps): JSX.Element;
