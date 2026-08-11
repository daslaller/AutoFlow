/** Work-item pipeline status pill. Colors are fixed semantics — never reassign a status to a different color. @startingPoint section="Domain" subtitle="Work-item pipeline status pill (8 states)" viewport="700x120" */
export interface StatusBadgeProps{ status:'backlog'|'triage'|'blocked'|'in_progress'|'review'|'ready'|'done'|'cancelled'; }
export function StatusBadge(props: StatusBadgeProps): JSX.Element;
