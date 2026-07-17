/** Inline callout banner (low-stock warnings, AI price hints, join-code errors). @startingPoint section="Feedback" subtitle="Inline info/warning/success callout" viewport="700x160" */
export interface AlertProps{ kind?:'info'|'warning'|'success'|'destructive'; title?:string; children?: React.ReactNode; }
export function Alert(props: AlertProps): JSX.Element;
