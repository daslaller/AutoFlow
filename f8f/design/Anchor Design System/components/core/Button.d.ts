/**
 * Primary action button — 7 variants (solid blue default, blue→purple gradient for AI/quick actions, outline/ghost for secondary).
 * @startingPoint section="Core" subtitle="Buttons with all variants and sizes" viewport="700x120"
 */
export interface ButtonProps{
  variant?: 'default'|'destructive'|'outline'|'secondary'|'ghost'|'link'|'gradient';
  size?: 'default'|'sm'|'lg'|'icon';
  disabled?: boolean;
  onClick?: ()=>void;
  children?: React.ReactNode;
}
export function Button(props: ButtonProps): JSX.Element;
