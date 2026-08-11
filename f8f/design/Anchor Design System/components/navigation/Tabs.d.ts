/** Tab switcher (used on Onboarding: Create Company / Join Company). Source .jsx for this was not present in the manual repo export; rebuilt to match on-screen usage. @startingPoint section="Navigation" subtitle="Segmented tab switcher" viewport="700x150" */
export interface TabDef{ value:string; label:string; }
export interface TabsProps{ value:string; onValueChange:(v:string)=>void; tabs:TabDef[]; children?: React.ReactNode; }
export function Tabs(props: TabsProps): JSX.Element;
