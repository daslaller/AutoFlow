/**
 * Base surface for every content block — white, no border, shadow-md, rounded-xl. Compose with CardHeader/CardTitle/CardContent/CardFooter.
 * @startingPoint section="Core" subtitle="Elevated white surface with header/content/footer slots" viewport="700x260"
 */
export interface CardProps{ children?: React.ReactNode; style?: React.CSSProperties; }
export function Card(props: CardProps): JSX.Element;
export function CardHeader(props: CardProps): JSX.Element;
export function CardTitle(props: CardProps): JSX.Element;
export function CardDescription(props: CardProps): JSX.Element;
export function CardContent(props: CardProps): JSX.Element;
export function CardFooter(props: CardProps): JSX.Element;
