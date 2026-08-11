/** Draggable work-item card on the Kanban board. Left border color = priority; badge color = category. Drag interaction itself is not reproduced — this is the static visual. @startingPoint section="Domain" subtitle="Work-item card — priority border + category badge" viewport="700x180" */
export interface KanbanCardProps{ title:string; detail?:string; category?:'Bug'|'Feature'|'Task'|'Project'|'Other'; tags?:string[]; priority?:'low'|'medium'|'high'|'urgent'; assigneeInitial?:string; onClick?:()=>void; }
export function KanbanCard(props: KanbanCardProps): JSX.Element;
