/** Expand/collapse list of Q&A-style sections. @startingPoint section="Data Display" subtitle="Expand/collapse sections" viewport="700x180" */
export interface AccordionItem{ title:string; content: React.ReactNode; }
export interface AccordionProps{ items: AccordionItem[]; }
export function Accordion(props: AccordionProps): JSX.Element;
