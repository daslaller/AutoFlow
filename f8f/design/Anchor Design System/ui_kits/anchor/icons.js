window.AnchorIcon = function AnchorIcon({name,size=16,color='currentColor',style}){
  const url = 'https://unpkg.com/lucide-static@latest/icons/'+name+'.svg';
  return React.createElement('span',{style:{display:'inline-block',width:size,height:size,backgroundColor:color,WebkitMaskImage:'url('+url+')',maskImage:'url('+url+')',WebkitMaskSize:'contain',maskSize:'contain',WebkitMaskRepeat:'no-repeat',maskRepeat:'no-repeat',flexShrink:0,...style}});
};
