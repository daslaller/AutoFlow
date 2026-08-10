function DashboardScreen({onNavigate}){
  const NS=window.FlowStockDesignSystem_93f696;
  const {Card,CardHeader,CardTitle,CardContent,Button,Input,Badge}=NS;
  const {MetricCard,StatusBadge}=NS;
  const Icon=window.AnchorIcon;
  const items=window.ANCHOR_DATA.items;
  const assets=window.ANCHOR_DATA.assets;
  const [quickInput,setQuickInput]=React.useState('');
  const [parsing,setParsing]=React.useState(false);
  const activeItems=items.filter(j=>!['done','cancelled'].includes(j.status));
  const completed=items.filter(j=>j.status==='done').length;
  const lowStock=assets.filter(i=>i.current_stock<=i.min_stock_level);
  const assetValue=assets.reduce((s,i)=>s+i.current_stock*(i.sale_price||0),0);
  const completion=items.length?((completed/items.length)*100).toFixed(1):0;
  const submitQuick=e=>{e.preventDefault(); if(!quickInput.trim())return; setParsing(true); setTimeout(()=>{setParsing(false); onNavigate('intake',{raw:quickInput});},900);};
  return (
    <div style={{padding:24,background:'var(--gradient-page)',minHeight:'100%',display:'flex',flexDirection:'column',gap:24}}>
      <div><h1 style={{fontSize:24,fontWeight:700,margin:0,color:'var(--foreground)'}}>Dashboard</h1><p style={{color:'var(--muted-foreground)',fontSize:13,margin:'2px 0 0'}}>Acme Co · Monday, Jul 13</p></div>
      <div style={{background:'var(--gradient-brand)',borderRadius:12,boxShadow:'var(--shadow-md)',padding:16}}>
        <p style={{color:'#dbeafe',fontSize:12,fontWeight:600,display:'flex',alignItems:'center',gap:6,margin:'0 0 8px'}}><Icon name="zap" size={12} color="#dbeafe"/>Quick Add — type a task and hit Enter</p>
        <form onSubmit={submitQuick} style={{display:'flex',gap:8}}>
          <Input value={quickInput} onChange={e=>setQuickInput(e.target.value)} placeholder="e.g. Fix the checkout timeout bug" disabled={parsing} style={{flex:1,height:44,background:'rgba(255,255,255,0.1)',border:'1px solid rgba(255,255,255,0.2)',color:'#fff'}}/>
          <Button type="submit" disabled={parsing||!quickInput.trim()} style={{height:44,background:'#fff',color:'var(--blue-700)'}}>{parsing?'...':(<React.Fragment><Icon name="zap" size={14}/>Go</React.Fragment>)}</Button>
        </form>
      </div>
      <div style={{display:'grid',gridTemplateColumns:'repeat(4,1fr)',gap:16}}>
        <MetricCard title="Active Items" value={activeItems.length} sub={completion+'% completion rate'} color="blue" iconGlyph={<Icon name="list-checks" size={18} color="#fff"/>}/>
        <MetricCard title="Completed" value={completed} sub="All time" color="green" iconGlyph={<Icon name="circle-check" size={18} color="#fff"/>}/>
        <MetricCard title="Asset Value" value={'$'+assetValue.toLocaleString()} sub={assets.length+' items'} color="purple" iconGlyph={<Icon name="dollar-sign" size={18} color="#fff"/>}/>
        <MetricCard title="Low Stock" value={lowStock.length} sub={lowStock.length?'Needs attention':'All good'} color={lowStock.length?'red':'blue'} iconGlyph={<Icon name="triangle-alert" size={18} color="#fff"/>}/>
      </div>
      <div style={{display:'grid',gridTemplateColumns:'2fr 1fr',gap:24}}>
        <Card>
          <CardHeader style={{flexDirection:'row',justifyContent:'space-between',alignItems:'center'}}>
            <CardTitle style={{display:'flex',alignItems:'center',gap:8}}><Icon name="clock" size={16} color="var(--blue-500)"/>Recent Activity</CardTitle>
            <Button variant="ghost" size="sm" onClick={()=>onNavigate('kanban')} style={{color:'var(--blue-600)'}}>View all →</Button>
          </CardHeader>
          <CardContent style={{padding:0}}>
            {items.slice(0,6).map(item=>(
              <div key={item.id} onClick={()=>onNavigate('kanban')} style={{display:'flex',justifyContent:'space-between',alignItems:'center',padding:'12px 20px',borderTop:'1px solid var(--border)',cursor:'pointer'}}>
                <div style={{minWidth:0}}><p style={{fontSize:14,fontWeight:600,margin:0,color:'var(--slate-800)'}}>{item.title}</p><p style={{fontSize:12,color:'var(--muted-foreground)',margin:'2px 0 0'}}>{item.owner}</p></div>
                <StatusBadge status={item.status}/>
              </div>
            ))}
          </CardContent>
        </Card>
        <div style={{display:'flex',flexDirection:'column',gap:16}}>
          <Card><CardHeader><CardTitle style={{display:'flex',alignItems:'center',gap:8}}><Icon name="trending-up" size={16} color="var(--purple-500)"/>Work Pipeline</CardTitle></CardHeader>
            <CardContent style={{display:'flex',flexDirection:'column',gap:8}}>
              {['backlog','triage','blocked','in_progress','review','ready'].map(s=>{
                const count=items.filter(j=>j.status===s).length;
                return <div key={s} style={{display:'flex',justifyContent:'space-between'}}><span style={{fontSize:13,color:'var(--slate-600)',textTransform:'capitalize'}}>{s.replace('_',' ')}</span><StatusBadge status={s}/></div>;
              })}
            </CardContent>
          </Card>
          {lowStock.length>0 && <Card style={{background:'var(--red-50)'}}>
            <CardHeader><CardTitle style={{fontSize:14,color:'var(--red-700)',display:'flex',alignItems:'center',gap:8}}><Icon name="triangle-alert" size={14} color="var(--red-700)"/>Low Stock ({lowStock.length})</CardTitle></CardHeader>
            <CardContent style={{display:'flex',flexDirection:'column',gap:8}}>
              {lowStock.map(i=>(<div key={i.id} style={{display:'flex',justifyContent:'space-between',fontSize:12}}><span style={{color:'var(--slate-700)',fontWeight:500}}>{i.name}</span><Badge variant="destructive">{i.current_stock}</Badge></div>))}
            </CardContent>
          </Card>}
        </div>
      </div>
    </div>
  );
}
window.DashboardScreen = DashboardScreen;
