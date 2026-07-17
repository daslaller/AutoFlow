/** Dashboard top-row KPI tile (Active Items / Completed / Asset Value / Low Stock). Icon renders as a gradient-tile glyph here; in production swap for the matching lucide-react icon. @startingPoint section="Domain" subtitle="Dashboard KPI tile with gradient icon chip" viewport="700x140" */
export interface MetricCardProps{ title:string; value:string|number; sub?:string; color?:'blue'|'green'|'purple'|'red'; iconGlyph?:string; }
export function MetricCard(props: MetricCardProps): JSX.Element;
