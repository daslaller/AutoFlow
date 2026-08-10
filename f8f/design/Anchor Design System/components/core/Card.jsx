import React from 'react';
export function Card({style,children,...props}){
  return React.createElement('div',{style:{background:'var(--card)',borderRadius:'var(--radius-xl)',border:'none',boxShadow:'var(--shadow-md)',color:'var(--card-foreground)',...style},...props},children);
}
export function CardHeader({style,children,...props}){return React.createElement('div',{style:{padding:'20px 20px 8px',display:'flex',flexDirection:'column',gap:'4px',...style},...props},children);}
export function CardTitle({style,children,...props}){return React.createElement('div',{style:{fontWeight:700,fontSize:'16px',lineHeight:1.2,...style},...props},children);}
export function CardDescription({style,children,...props}){return React.createElement('div',{style:{fontSize:'13px',color:'var(--muted-foreground)',...style},...props},children);}
export function CardContent({style,children,...props}){return React.createElement('div',{style:{padding:'20px',paddingTop:0,...style},...props},children);}
export function CardFooter({style,children,...props}){return React.createElement('div',{style:{padding:'20px',paddingTop:0,display:'flex',alignItems:'center',...style},...props},children);}
