/** Radio button group for single-choice fields (e.g. device condition). @startingPoint section="Forms" subtitle="Single-choice radio list" viewport="700x120" */
export interface RadioOption{ value:string; label:string; }
export interface RadioGroupProps{ value?:string; onValueChange?:(v:string)=>void; options:RadioOption[]; }
export function RadioGroup(props: RadioGroupProps): JSX.Element;
