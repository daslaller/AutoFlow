/** Checkbox input. @startingPoint section="Forms" subtitle="Checkbox with accent color" viewport="700x60" */
export interface CheckboxProps{ checked?:boolean; onCheckedChange?:(v:boolean)=>void; }
export function Checkbox(props: CheckboxProps): JSX.Element;
