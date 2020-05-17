double2 twosum(const double2 a)
{
	double x = (a.x + a.y);
	double tmp= (x - a.x);
	double y = (a.x - (x - tmp)) + (a.y - tmp);
	return (double2){x,y};
}

double2 dsplit(const double a)
{
	double tmp = (a * 134217729.0);
	double x = (tmp - (tmp - a));
	double y = (a - x);
	return (double2){x,y};
}

double2 twoproduct(const double2 a)
{
	double x = a.x * a.y;
#ifdef IntelGPU
	if (x>99991999195818789123.11)x=(1.1*a.x+0.234) / (4.11+a.y);//コンパイラによる過剰な最適化の防止の呪文
#endif
	double2 ca = dsplit(a.x);
	double2 cb = dsplit(a.y);
	double y = (((ca.x * cb.x - x) + ca.y * cb.x) + ca.x * cb.y) + ca.y * cb.y;
	return (double2){x,y};
}

double2 addcab(const double2 a,const double2 b)
{
	double2 tmp={a.x,b.x};
	double2 cz = twosum(tmp);
	cz.y = cz.y + a.y + b.y;
	return twosum(cz);
}

double2 subcab(const double2 a,const double2 b)
{
	double2 tmp={a.x,-b.x};
	double2 cz = twosum(tmp);
	cz.y = cz.y + a.y - b.y;
	return twosum(cz);
}

double2 ddmulcab(const double2 a,const double2 b)
{
	double2 tmp={a.x,b.x};
	double2 cz = twoproduct(tmp);
	cz.y = cz.y + a.x * b.y + a.y * b.x + a.y * b.y;
	return twosum(cz);
}


double2 dnmulcab(const double2 a,const double b)
{
	double2 tmp={a.x,b};
	double2 cz = twoproduct(tmp);
	cz.y = cz.y + a.y * b;
	return twosum(cz);
}

double2 nnmulcab(const double a,const double b)
{
	double2 tmp={a,b};
	double2 cz = twoproduct(tmp);
	return cz;
}


double2 dd_div(const double2 x,const double2 y)
{
	double z1 = x.x / y.x;
	double2 tmp={-z1,y.x};
	double2 cz = twoproduct(tmp);
	double z2 = ((((cz.x + x.x) - z1 * y.y) + x.y) + cz.y) / y.x;
	return twosum((double2){z1,z2});
}


double2 dn_div(const double2 x,const double y)
{
	double z1 = x.x / y;
	double2 tmp={-z1,y};
	double2 cz = twoproduct(tmp);
	double z2 = (((cz.x + x.x) + x.y) + cz.y) / y;
	return twosum((double2){z1,z2});
}

double2 nd_div(const double x,const double2 y)
{
	double z1 = x / y.x;
	double2 tmp={-z1,y.x};
	double2 cz = twoproduct(tmp);
	double z2 = (((cz.x + x) - z1 * y.y) + cz.y) / y.x;
	return twosum((double2){z1,z2});
}


double2 nn_div(const double x,const double y)
{
	double z1 = x / y;
	double2 tmp={-z1,y};
	double2 cz = twoproduct(tmp);
	double z2 = ((cz.x + x) + cz.y) / y;
	return twosum((double2){z1,z2});
}


























//1:only modC >= (1<<32)
//2:only a*b<modC*modC
//return a*b mod modC
ulong ABmodC64(const ulong a,const ulong b,const ulong modC)
{
	ulong xc=(((ulong)1<<(ulong)63)%modC)*(ulong)2;
	xc-=(xc>=modC)*modC;
	ulong anslo=a*b; // (64bit)
	ulong anshi=mul_hi(a,b); // (64bit)
	ulong c1=modC>>(ulong)32; // (32bit)
	ulong c2=modC%((ulong)1<<(ulong)32); // ull c2=c&0x00000000FFFFFFFF; 
	// In actuality, c1 c2 are not calculate per for loops
	ulong s=anshi/c1; // (64bit)/(32bit)=(32bit)
	if (s>c1) s=c1;
	anshi-=s*c1; // (64bit)-(32bit)*(32bit)=(32bit) there is no underflow possibility 
	ulong scfrg=s*c2;// (32bit)*(32bit)=(64bit)
	anshi-=scfrg>>(ulong)32; //(32bit)-((64bit)>>32)=(32bit or underflow)
	scfrg<<=(ulong)32; //((64bit)%(32bit))<<32=(64bit)  32-63bit usd
	//anshi-=(anslo<scfrg); // (64bit)<(64bit)   (32bit or underflow)-(1bit)=(32bit or underflow)
	if (anslo<scfrg)anshi--;
	anslo-=scfrg; // (64bit)-(64bit)=(64bit or underflow).This underflow is already resolved.
	ulong anslo_tmp=anslo;
	if (anshi>((ulong)1<<(ulong)63))
	{ // faster than anshi&8000000000000000
		anshi+=c1; // (32bit or underflow)+(32bit)=(32bit)
		anslo+=c2<<(ulong)32; //(64bit)+(32bit)*(1bit)*(32bit)=(64bit or overflow)
	}
	if (anslo<anslo_tmp)anshi++;
	s=( anshi*((ulong)1<<(ulong)32) + (anslo>>(ulong)32) ) /c1; // ( ((32bit)<<32) + ((64bit)>>32) )/(32bit)=(32bit)
	scfrg=s*c1; // (32bit)*(32bit)=(64bit)
	anshi-=scfrg>>(ulong)32; // (32bit)-((64bit)>>32)=(32bit) there is no underflow possibility. 
	scfrg<<=(ulong)32; // ( ((64bit)%(32bit))<<32 )=(64bit) 32-63bit use
	if (anslo<scfrg)anshi--;
	anslo-=scfrg; // (64bit)-(64bit)=(64bit or underflow).This underflow is already resolved.
	scfrg=s*c2; // (32bit)*(32bit)=(64bit)
	if (anslo<scfrg)anshi--;
	anslo-=scfrg; // (64bit)-(64bit)=(64bit or underflow) This underflow is already resolved.
	anshi-=mul_hi(s,c2);
	if (anshi>((ulong)1<<(ulong)63))
	{
		anslo=(ulong)0-anslo;
	}
	ulong resans=anslo%modC;
	if (anshi>((ulong)1<<(ulong)63))
	{
		if (anslo!=(ulong)0)anshi++;
		resans=(modC*(ulong)2-resans-((ulong)0-anshi)*xc);
		if (resans>=modC)resans-=modC;
		if (resans>=modC)resans-=modC;
	}
	return resans;
}







uint modinv32(const uint m)
{
/*
#ifdef CPU
	uint NR = 0;
	uint t = 0;
	uint vi = 1;
	for(int i=0;i<32;i++)
	{
		if ( (t & 0x00000001) == 0){
			t += m;
			NR += vi;
		}
		t >>= 1;
		vi <<= 1;
	}
	return NR;
#else
*/
	uint inv=m;
	for(int i=0;i<4;i++){
		inv*=2-inv*m;
	}
	return -inv;
//#endif
}

ulong modinv64(const ulong m)
{
#ifdef IntelGPU
	ulong NR = 0;
	ulong t = 0;
	ulong vi = 1;
	for(int i=0;i<64;i++)
	{
		if ( (t & 0x0000000000000001) == (ulong)0){
			t += m;
			NR += vi;
		}
		t >>= 1;
		vi <<= 1;
	}
	return NR;
#else
	
	//本当は下のコメントアウトしているやつにしたかったがコンパイル時間が非常に長くなったのでwhile構文つかってアンロールされないようにしている
	ulong minv=m;
	ulong tmp=0;
	while((tmp & 0x00000000FFFFFFFF)!=(ulong)1){
		tmp=minv*m;
		minv*=(ulong)2-tmp;
	}
	return -minv;
#endif
	
	/*
	ulong minv=m;
	ulong tmp;
	for(int i=0;i<5;i++){
		minv=minv*((ulong)2-minv*m);
	}
	return -minv;
	*/
	
}









//除数決め打ちなのを利用して乗算とビットシフトだけに書き換えたバージョン
//a*b % modC
ulong ABmodC64v3(const ulong a,const ulong b,const ulong modC,const ulong rmodC,const ulong log2modC)
{
	ulong blo=a*b;
	ulong bhi=mul_hi(a,b);
	ulong b1=(bhi<<((ulong)64-log2modC))|(blo>>log2modC);
	ulong b2lo=b1*rmodC;
	ulong b2hi=mul_hi(b1,rmodC);
	ulong b2=(b2hi<<((ulong)64-log2modC))|(b2lo>>log2modC);
	ulong b2alo=b2*modC;
	ulong b2ahi=mul_hi(b2,modC);
	
	bhi-=b2ahi;
	if (blo<b2alo)bhi-=1;
	blo-=b2alo;
	if (bhi==(ulong)18446744073709551615){
		bhi=0;
		blo+=modC;
	}
	
	//この時点でbは最大4modC-1
	if (bhi>0){
		if (blo<modC)bhi-=1;
		blo-=modC;
	}
	//この時点でbの最大は4modC-1
	if (blo>=modC){
		blo-=modC;
	}
	//この時点でbの最大は3modC-1
	if (blo>=modC){
		blo-=modC;
	}
	
	//この時点でbの最大は2modC-1
	if (blo>=modC){
		blo-=modC;
	}
	
	return blo;
}






ulong ExpMod32(ulong a,ulong n,const ulong modC){
	ulong ans=1;
	for(int i=0;i<64;i++){
		if (n%2==1){
			ans=(ans*a)%modC;
		}
		a=a*a%modC;
		n/=2;
		if (n==0)break;
	}
	return ans;
}


ulong ExpMod64(ulong a,ulong n,const ulong modC){
	ulong ans=1;
	for(int i=0;i<64;i++){
		if (n%(ulong)2==(ulong)1){
			ans=ABmodC64(ans,a,modC);
		}
		a=ABmodC64(a,a,modC);
		n/=(ulong)2;
		if (n==(ulong)0)break;
	}
	return ans;
}


//a=1024の冪剰余に固定、最適化
ulong ExpMod64v3(ulong n,const ulong modC,const ulong rmodC,const ulong log2modC){
	ulong a;
	ulong ans=1;
	//loop0
	if (n%2==1){
		ans=1024;
	}
	//a=1024*1024;//1048576
	n/=2;
	//loop0ここまで
	//if (n==0)break;
	//loop1
	if (n%2==1){
		ans=1048576*ans;//最大で2^30
	}
	a=ABmodC64v3(1048576,1048576,modC,rmodC,log2modC);//1048576
	n/=2;
	//loop1ここまで
	
	for(int i=0;i<62;i++){
		if (n%2==1){
			ans=ABmodC64v3(ans,a,modC,rmodC,log2modC);
		}
		if (n<=1)break;
		a=ABmodC64v3(a,a,modC,rmodC,log2modC);
		n/=2;
	}
	return ans;
}







//モンゴメリリダクション32bit版
uint MR32(const uint xlo,const uint xhi,const uint inv,const uint modC)
{
	uint xinv=xlo*inv;
	uint ret=mul_hi(xinv,modC);
	if (xlo!=0)ret++;//分かりにくいが、xinv*modC+xloは必ずRで割り切れるので
	//ret+=xhi;//これはオーバーフローするかもしれないので以下4行
	uint ans=ret+xhi;
	if ((ans>=modC)|(ans<xhi)){
		ans-=modC;
	}
	return ans;
}


//a=1024のn乗% modC、モンゴメリ乗算32bit、最適化
uint ExpMod32v4(ulong n,const uint modC,const uint inv,const uint r2){
	//uint a=1024;
	uint p=MR32(r2<<10,r2>>22,inv,modC);//10は1024=2^10の10
	uint x=MR32(r2,0,inv,modC);
	for(int i=0;i<64;i++){
		if (n%(ulong)2==(ulong)1){
			x=MR32(x*p,mul_hi(x,p),inv,modC);
		}
		p=MR32(p*p,mul_hi(p,p),inv,modC);
		n/=(ulong)2;
		if (n==(ulong)0)break;
	}
	return MR32(x,0,inv,modC);
}







//モンゴメリリダクション
ulong MR64(const ulong xlo,const ulong xhi,const ulong inv,const ulong modC)
{
	ulong xinv=xlo*inv;
	ulong ret=mul_hi(xinv,modC);
	if (xlo!=0)ret++;//分かりにくいが、xinv*modC+xloは必ずRで割り切れるので
	//ret+=xhi;//これはオーバーフローするかもしれないので以下4行
	ulong ans=ret+xhi;
	if ((ans>=modC)|(ans<xhi)){//ans==modCの場合も同時に処理
		ans-=modC;
	}
	return ans;

}


//a=1024のn乗MOD c、モンゴメリ乗算、最適化
ulong ExpMod64v4(ulong n,const ulong modC,const ulong inv,const ulong r2){
	ulong a=1024;
	ulong p=MR64(r2<<(ulong)10,r2>>(ulong)54,inv,modC);
	ulong x=MR64(r2,0,inv,modC);
	for(int i=0;i<64;i++){
		if (n%(ulong)2==(ulong)1){
			x=MR64(x*p,mul_hi(x,p),inv,modC);
		}
		
		p=MR64(p*p,mul_hi(p,p),inv,modC);
		n/=(ulong)2;
		if (n==(ulong)0)break;
	}
	return MR64(x,0,inv,modC);
}









//小数点以下のみの抽出をやってる、マイナスも考慮
void sumfix2(double2 *sum)
{
	double2 ddtmp;
	ddtmp.x=(*sum).x;//sum->xだと怒られた
	ddtmp.y=0.0;
	if ((*sum).x>=1.0)
	{
		ddtmp.y=-1.0;
	}
	if ((*sum).x<=-1.0)
	{
		ddtmp.y=1.0;
	}
	ddtmp=twosum(ddtmp);
	ddtmp.y+=(*sum).y;
	*sum=twosum(ddtmp);
}

//小数点以下のみの抽出をやってる、マイナスは考慮してない
void sumfix(double2 *sum)
{
	if ((*sum).x>=1.0){
		double2 ddtmp;
		ddtmp.x=(*sum).x;
		ddtmp.y=-1.0;
		ddtmp=twosum(ddtmp);
		ddtmp.y+=(*sum).y;
		*sum=twosum(ddtmp);
	}
}



//double-double精度を2つ使って192bitに結果を収める。上のループと比べると試行回数は１回なので少し非効率でも大丈夫
void dd2_to_ulong3(double2 d2sum0,double2 d2sum1,ulong *outul0,ulong *outul1,ulong *outul2){
	double2 d2tmp;
	d2tmp.x=1.0;d2tmp.y=0.0;
	if (d2sum0.x<0.0){
		d2sum0=addcab(d2sum0,d2tmp);
	}
	if (d2sum1.x<0.0){
		d2sum1=addcab(d2sum1,d2tmp);
	}
	ulong ulsum0=0;//最上位桁
	ulong ulsum1=0;//中間
	ulong ulsum2=0;//最下位桁
	
	ulong ultemp;
	double dtmp;
	d2sum0.x*=4503599627370496.0;//2^52
	d2sum0.y*=4503599627370496.0;//2^52
	dtmp=trunc(d2sum0.x);//必ず切り下げ整数切り出ししないといけない
	ulsum0=(((ulong)dtmp)*(ulong)4096);
	d2sum0.x-=dtmp;
	d2sum0=twosum(d2sum0);//次の52bitを切り出したい
	d2sum0.x*=4503599627370496.0;//2^52
	if (d2sum0.x<0.0){
		d2sum0.x+=4503599627370496.0;
		ulsum0-=(ulong)4096;
	}
	ultemp=(ulong)d2sum0.x;
	ulsum0|=ultemp>>((ulong)40);//これでulsum0は確定
	ulsum1=(ultemp%((ulong)1<<(ulong)40))<<((ulong)24);
	//ここでいったんulsum1は保留、ulsum2を埋める。d2sum1から96bit切り出す
	d2sum1.x*=281474976710656.0;//2^48
	d2sum1.y*=281474976710656.0;//2^48
	dtmp=trunc(d2sum1.x);//必ず切り下げ整数切り出ししないといけない
	ultemp=(ulong)dtmp;
	d2sum1.x-=dtmp;
	d2sum1=twosum(d2sum1);//次の48bitを切り出したい
	d2sum1.x*=281474976710656.0;//2^48
	if (d2sum1.x<0.0){
		d2sum1.x+=281474976710656.0;
		ultemp--;
	}
	ulsum2=(ultemp%((ulong)1<<(ulong)16))<<((ulong)48);
	ulsum2+=(ulong)d2sum1.x;//ここはtruncを使わないほうが正解に近い
	//ultempの48bit中上32bitが残っている
	uint chk0=(uint)((ulsum1>>((ulong)30))%(ulong)4);//30と31bit目を切り出し
	uint chk1=(uint)(ultemp>>((ulong)46));//46と47bit目を切り出し
	if (chk0==chk1){//何も考えずコピーで良い
		//ulsum1=(ulsum1&0xFFFFFFFF00000000)|(ultemp>>((ulong)16));
	}else{
		ulong last_ulsum1=ulsum1;
		if (((chk0+1)%4)==chk1){//chk1が正解の数字なのでchk0側つまりulsum1とulsum0を修正しないといけない
			ulsum1+=((ulong)1<<(ulong)30);
			//繰り上がりあるなら
			if (ulsum1<last_ulsum1)ulsum0++;
			//ulsum1=(ulsum1&0xFFFFFFFF00000000)|(ultemp>>((ulong)16));
		}
		
		if (((chk0-1)%4)==chk1){//chk1が正解の数字なのでchk0側つまりulsum1とulsum0を修正しないといけない
			ulsum1-=((ulong)1<<(ulong)30);
			//繰り下がりあるなら
			if (ulsum1>last_ulsum1)ulsum0--;
			//ulsum1=(ulsum1&0xFFFFFFFF00000000)|(ultemp>>((ulong)16));
		}
		//これ以外のパターンは想定外、一応ないと証明できている。
	}
	ulsum1=(ulsum1&0xFFFFFFFF00000000)|(ultemp>>((ulong)16));
	//192bit　sumの完成!!!
	
	*outul0=ulsum0;
	*outul1=ulsum1;
	*outul2=ulsum2;
	return;
}



//シェアードメモリ内でdd加算して結果をlocal_id 0のsumにまとめる
void shared_reduction_dd(double2 *sum,__local double2 *p)
{
	uint lidx=get_local_id(0);
	p[lidx]=*sum;
	for(uint i=128;i>0;i/=2)
	{
		barrier(CLK_LOCAL_MEM_FENCE);
		if (lidx<i){
			*sum=addcab(p[lidx],p[lidx+i]);
			sumfix2(sum);
			p[lidx]=*sum;
		}
	}
}



//1threadあたりulongを3つもっているので256threadで全部結果をまとめて繰り上がり処理して結果をグローバルメモリに書き込み
void shared_reduction_ulong3(ulong* ulsum0_,ulong* ulsum1_,ulong* ulsum2_,__local ulong* p){
	//shared memoryは4or8kbまで使えるので、とりあえず4として
	ulong ulsum0=*ulsum0_;
	ulong ulsum1=*ulsum1_;
	ulong ulsum2=*ulsum2_;

	uint lidx=get_local_id(0);
	if (lidx>=128){
		p[(lidx%128)*3+2]=ulsum2;
		p[(lidx%128)*3+1]=ulsum1;
		p[(lidx%128)*3+0]=ulsum0;
	}
	barrier(CLK_LOCAL_MEM_FENCE);
	if (lidx<128){
		p[lidx*3+2]+=ulsum2;
		if (p[lidx*3+2]<ulsum2){//繰り上がり考慮
			ulsum1++;
			if (ulsum1==0)ulsum0++;//繰り上がり考慮
		}
		p[lidx*3+1]+=ulsum1;
		if (p[lidx*3+1]<ulsum1)ulsum0++;//繰り上がり考慮
		p[lidx*3+0]+=ulsum0;
	}
	
	ulong dmy0,dmy1,dmy2;
	for(uint i=64;i>0;i/=2)
	{
		barrier(CLK_LOCAL_MEM_FENCE);
		if (lidx<i){
			ulsum0=p[lidx*3+0];
			ulsum1=p[lidx*3+1];
			ulsum2=p[lidx*3+2];
			dmy0=p[(lidx+i)*3+0];
			dmy1=p[(lidx+i)*3+1];
			dmy2=p[(lidx+i)*3+2];
			ulsum2+=dmy2;
			if (ulsum2<dmy2){
				dmy1++;
				if (dmy1==0)dmy0++;
			}
			ulsum1+=dmy1;
			if (ulsum1<dmy1)dmy0++;
			ulsum0+=dmy0;
			p[lidx*3+0]=ulsum0;
			p[lidx*3+1]=ulsum1;
			p[lidx*3+2]=ulsum2;
		}
	}
	
	*ulsum0_=ulsum0;
	*ulsum1_=ulsum1;
	*ulsum2_=ulsum2;
}


//グローバルメモリに加算書き込み
void ulong3GlobalADD(ulong ulsum0,ulong ulsum1,ulong ulsum2,__global ulong* bigSum)
{
	if (get_local_id(0)==0){
		ulong dmy0=bigSum[get_group_id(0)*3+0];
		ulong dmy1=bigSum[get_group_id(0)*3+1];
		ulong dmy2=bigSum[get_group_id(0)*3+2];
		ulsum2+=dmy2;
		if (ulsum2<dmy2){
			dmy1++;
			if (dmy1==0)dmy0++;
		}
		ulsum1+=dmy1;
		if (ulsum1<dmy1)dmy0++;
		ulsum0+=dmy0;
		bigSum[get_group_id(0)*3+0]=ulsum0;
		bigSum[get_group_id(0)*3+1]=ulsum1;
		bigSum[get_group_id(0)*3+2]=ulsum2;
	}
}

















/////////////////////////32bitバージョン　ルーチン//////////////////////
//local_work_size=256に固定、最後にshared memoryでリダクションして結果をbigSumに格納
__kernel void Sglobal32(__global double2 *bigSum,const ulong offset,const ulong d,const ulong k_max,const long numesign,const ulong den0,const ulong den1) {
	ulong gsize=get_global_size(0);//global_work_item数
	ulong idx = get_global_id(0);
	ulong k=idx+offset;
	ulong dnm;//分母
	ulong nmr;//分子
	double2 sum=0.0;
	double2 d2tmp;
	for(;k<k_max;k+=gsize)
	{
		dnm=den0*k+den1;
		nmr=ExpMod32(1024,d-k,dnm);//*nume
		d2tmp=nn_div((double)nmr,(double)dnm);
		sum=addcab(sum,d2tmp);
		sumfix(&sum);
	}
	
	if ((numesign+k%2)%2==1){
		sum=-sum;
	}
	
	//シェアードメモリ内でdd加算して結果をglobalメモリに加算出力
	__local double2 p[256];
	shared_reduction_dd(&sum,p);
	if (get_local_id(0)==0){
		sum=addcab(bigSum[get_group_id(0)],sum);
		sumfix2(&sum);
		bigSum[get_group_id(0)]=sum;
	}
}


//メイン計算部分モンゴメリ乗算版32bit
//local_work_size=256に固定、最後にshared memoryでリダクションして結果をbigSumに格納
__kernel void Sglobal32mtg(__global double2 *bigSum,const ulong offset,const ulong d,const ulong k_max,const long numesign,const ulong den0,const ulong den1) {
	ulong gsize=get_global_size(0);//global_work_item数
	ulong idx = get_global_id(0);
	ulong k=idx+offset;
	ulong dnm=den0*k+den1;//分母
	uint nmr;//分子
	double2 sum=0.0;
	double2 d2tmp;
	uint dnminv;
	uint r2;
	for(;k<k_max;k+=gsize)
	{
		dnminv=modinv32((uint)dnm);
		r2=(uint)(((ulong)18446744073709551615)%(dnm))+1;
		if (r2==(uint)dnm)r2=0;
		nmr=ExpMod32v4(d-(ulong)k,(uint)dnm,dnminv,r2);
		d2tmp=nn_div((double)nmr,(double)dnm);
		sum=addcab(sum,d2tmp);
		sumfix(&sum);
		dnm+=gsize*den0;
	}
	
	if ((numesign+k%2)%2==1){
		sum=-sum;
	}
	
	//シェアードメモリ内でdd加算して結果をglobalメモリに加算出力
	__local double2 p[256];
	shared_reduction_dd(&sum,p);
	if (get_local_id(0)==0){
		sum=addcab(bigSum[get_group_id(0)],sum);
		sumfix2(&sum);
		bigSum[get_group_id(0)]=sum;
	}
}





//メイン計算部分モンゴメリ乗算版32bit、ulong3に結果まとめるやつ
//local_work_size=256に固定、最後にshared memoryでリダクションして結果をbigSumに格納
__kernel void Sglobal32mtg_192(__global ulong *bigSum,const ulong offset,const ulong d,const ulong k_max,const long numesign,const ulong den0,const ulong den1) {
	ulong gsize=get_global_size(0);
	ulong idx = get_global_id(0);
	ulong k=idx+offset;
	ulong dnm=den0*k+den1;//分母
	uint nmr;//分子
	ulong nmr2;
	double2 sum0=0.0;
	double2 sum1=0.0;
	double2 d2tmp;
	uint dnminv;
	uint r2;
	for(;k<k_max;k+=gsize)
	{
		dnminv=modinv32((uint)dnm);
		r2=(uint)(((ulong)18446744073709551615)%(dnm))+1;
		if (r2==(uint)dnm)r2=0;
		nmr=ExpMod32v4(d-(ulong)k,(uint)dnm,dnminv,r2);
		if (sum0.x>0.0){//結果的にsumの中身が-1～1におさまるよう
			nmr2=dnm-(ulong)nmr;
		}else{
			nmr2=(ulong)nmr;
		}
		d2tmp=nn_div((double)nmr2,(double)dnm);
		if (sum0.x>0.0)d2tmp=-d2tmp;//結果的にsumの中身が-1～1におさまるよう
		sum0=addcab(sum0,d2tmp);
		//次に(nmr*(2^96)%dnm)/dnmを求める
		nmr2=((ulong)nmr*(ulong)r2)%dnm;
		nmr2=nmr2*((ulong)4294967296)%dnm;
		if (sum1.x>0.0)nmr2=dnm-nmr2;//結果的にsumの中身が-1～1におさまるよう
		d2tmp=nn_div((double)nmr2,(double)dnm);
		if (sum1.x>0.0)d2tmp=-d2tmp;//結果的にsumの中身が-1～1におさまるよう
		sum1=addcab(sum1,d2tmp);
		dnm+=gsize*den0;
	}
	
	if ((numesign+k%2)%2==1){
		sum0=-sum0;
		sum1=-sum1;
	}
	
	ulong ulsum0;//最上位桁
	ulong ulsum1;//中間
	ulong ulsum2;//最下位桁
	//double-double精度を2つ使って192bitに結果を収める。上のループと比べると試行回数は１回なので少し非効率でも大丈夫
	//ここがすごい長い！！！！！
	dd2_to_ulong3(sum0,sum1,&ulsum0,&ulsum1,&ulsum2);
	//256threadまとめる。正しい値をもっているのはlocalid=0のthreadだけ
	__local ulong p[128*3];
	shared_reduction_ulong3(&ulsum0,&ulsum1,&ulsum2,p);
	//グローバルメモリに加算書き込み
	ulong3GlobalADD(ulsum0,ulsum1,ulsum2,bigSum);
}


/////////////////////////32bitバージョン　ルーチンここまで//////////////////////



































/////////////////////////64bitバージョン　ルーチン//////////////////////

//メイン計算部分、64bit
//local_work_size=256に固定、最後にshared memoryでリダクションして結果をbigSumに格納
__kernel void Sglobal64(__global double2 *bigSum,const ulong offset,const ulong d,const ulong k_max,const long numesign,const ulong den0,const ulong den1) {
	ulong gsize=get_global_size(0);
	ulong idx = get_global_id(0);
	ulong k=idx+offset;
	ulong dnm=den0*k+den1;//分母
	ulong dnmadd=gsize*den0;
	ulong nmr;//分子
	double2 sum=0.0;
	double2 d2tmp;
	ulong rev_dnm;
	ulong log2dnm;
	ulong uiclz=clz(dnm);
	double dr1;
	log2dnm=64-uiclz;
	dr1=1.0*(double)((ulong)1<<log2dnm)*((ulong)1<<log2dnm);
	for(;k<k_max;k+=gsize)
	{
		if (uiclz!=clz(dnm)){
			uiclz--;
			log2dnm++;
			dr1*=4.0;
		}
		rev_dnm=(ulong)(dr1/(double)dnm);
		nmr=ExpMod64v3(d-k,dnm,rev_dnm,log2dnm);
		d2tmp=nn_div((double)nmr,(double)dnm);
		sum=addcab(sum,d2tmp);
		sumfix(&sum);
		dnm+=dnmadd;
	}
	
	if ((numesign+k%2)%2==1){
		sum=-sum;
	}
	
	//シェアードメモリ内でdd加算して結果をglobalメモリに加算出力
	__local double2 p[256];
	shared_reduction_dd(&sum,p);
	if (get_local_id(0)==0){
		sum=addcab(bigSum[get_group_id(0)],p[0]);
		sumfix2(&sum);
		bigSum[get_group_id(0)]=sum;
	}
}



//メイン計算部分モンゴメリ乗算版64bit
//local_work_size=256に固定、最後にshared memoryでリダクションして結果をbigSumに格納
__kernel void Sglobal64mtg(__global double2 *bigSum,const ulong offset,const ulong d,const ulong k_max,const long numesign,const ulong den0,const ulong den1) {
	ulong gsize=get_global_size(0);
	ulong idx = get_global_id(0);
	ulong k=idx+offset;
	ulong dnm=den0*k+den1;//分母
	ulong dnmadd=gsize*den0;
	ulong nmr;//分子
	double2 sum=0.0;
	double2 d2tmp;
	double2 d2dnm;
	double2 d2nmr;
	double2 d2rev_dnm;
	ulong dnminv;
	ulong r2;
	ulong log2dnm;
	double dr1;
	ulong rev_dnm;
	
	for(;k<k_max;k+=gsize)
	{
		dnminv=modinv64(dnm);//モンゴメリ乗算で必要
		log2dnm=64-clz(dnm);////モンゴメリ乗算で必要なr2の計算に必要
		dr1=1.0*(double)((ulong)1<<log2dnm)*((ulong)1<<log2dnm);
#ifdef OVERDOUBLE
		d2dnm.x=(double)dnm;
		d2dnm.y=(double)((long)dnm-(long)d2dnm.x);
		d2rev_dnm=nd_div(dr1,d2dnm);//dnmの逆数を計算、dd精度
		rev_dnm=(long)(d2rev_dnm.x)+(long)(d2rev_dnm.y);
#else
		//d2rev_dnm=nn_div();//dnmの逆数dd精度
		rev_dnm=(ulong)(dr1/(double)dnm);
#endif
		r2=((ulong)18446744073709551615)%dnm+(ulong)1;
		//if (r2==dnm)r2=0;//いらない
		r2=ABmodC64v3(r2,r2,dnm,rev_dnm,log2dnm);//モンゴメリ乗算で必要
		nmr=ExpMod64v4(d-k,dnm,dnminv,r2);
		
		ulong nmr2;
		if (sum.x>0.0){
			nmr2=dnm-nmr;
		}else{
			nmr2=nmr;
		}
#ifdef OVERDOUBLE
		d2nmr.x=(double)nmr2;//nmrが2^53を超えている
		d2nmr.y=(double)(((long)nmr2)-(long)d2nmr.x);//nmrが2^63未満であることが条件
		d2tmp=dd_div(d2nmr,d2dnm);
#else
		d2tmp=nn_div((double)nmr2,(double)dnm);
#endif
		if (sum.x>0.0)d2tmp=-d2tmp;
		sum=addcab(sum,d2tmp);
		//次のkを計算
		dnm+=dnmadd;
	}
	
	if ((numesign+k%2)%2==1){
		sum=-sum;
	}
	
	//シェアードメモリ内でdd加算して結果をglobalメモリに加算出力
	__local double2 p[256];
	shared_reduction_dd(&sum,p);
	if (get_local_id(0)==0){
		sum=addcab(bigSum[get_group_id(0)],p[0]);
		sumfix2(&sum);
		bigSum[get_group_id(0)]=sum;
	}
}







//メイン計算部分モンゴメリ乗算版64bit、2つのdouble-double(105bit*2)を64bit整数*3にまとめる
//local_work_size=256に固定、最後にshared memoryでリダクションして結果をbigSumに格納
__kernel void Sglobal64mtg_192(__global ulong *bigSum,const ulong offset,const ulong d,const ulong k_max,const long numesign,const ulong den0,const ulong den1) {
	ulong gsize=get_global_size(0);
	ulong idx = get_global_id(0);
	ulong k=idx+offset;
	ulong dnm=den0*k+den1;//分母
	ulong dnmadd=gsize*den0;
	ulong nmr;//分子
	double2 d2sum0=0;
	double2 d2sum1=0;
	double2 d2dnm;
	double2 d2nmr;
	double2 d2rev_dnm;
	double2 d2tmp;
	ulong dnminv;
	ulong r2;
	ulong r1;
	ulong log2dnm;
	double dr1;
	ulong rev_dnm;
	
	for(;k<k_max;k+=gsize)
	{
		dnminv=modinv64(dnm);//モンゴメリ乗算で必要
		log2dnm=64-clz(dnm);//モンゴメリ乗算で必要なr2の計算に必要
		dr1=1.0*(double)((ulong)1<<log2dnm)*((ulong)1<<log2dnm);
#ifdef OVERDOUBLE
		d2dnm.x=(double)dnm;
		d2dnm.y=(double)((long)dnm-(long)d2dnm.x);
		d2rev_dnm=nd_div(dr1,d2dnm);//dnmの逆数を計算、dd精度
		rev_dnm=(long)(d2rev_dnm.x)+(long)(d2rev_dnm.y);
#else
		rev_dnm=(ulong)(dr1/(double)dnm);
#endif
		r1=((ulong)18446744073709551615)%dnm+(ulong)1;
		//if (r1==dnm)r1=0;よく考えたらこれは必要ない dnmは奇数のため
		r2=ABmodC64v3(r1,r1,dnm,rev_dnm,log2dnm);//モンゴメリ乗算で必要
		//ここまでが初期値生成
		
		
		//べき剰余
		nmr=ExpMod64v4(d-k,dnm,dnminv,r2);
		ulong nmr2;
		if (d2sum0.x>0.0){//結果的にd2sumの中身が-1～1におさまるよう
			nmr2=dnm-nmr;
		}else{
			nmr2=nmr;
		}
		//次にnmr/dnmを求める
#ifdef OVERDOUBLE
		d2nmr.x=(double)nmr2;//nmrが2^53を超えている
		d2nmr.y=(double)(((long)nmr2)-(long)d2nmr.x);//nmrが2^63未満であることが条件
		d2tmp=dd_div(d2nmr,d2dnm);
#else
		d2tmp=nn_div((double)nmr2,(double)dnm);
#endif
		if (d2sum0.x>0.0)d2tmp=-d2tmp;//結果的にd2sumの中身が-1～1におさまるよう
		d2sum0=addcab(d2sum0,d2tmp);
		
		
		//次に(nmr*(2^96)%dnm)/dnmを求める
		nmr=ABmodC64v3(nmr,r1,dnm,rev_dnm,log2dnm);
		nmr=ABmodC64v3(nmr,(ulong)4294967296,dnm,rev_dnm,log2dnm);
		if (d2sum1.x>0.0){//結果的にd2sumの中身が-1～1におさまるよう
			nmr2=dnm-nmr;
		}else{
			nmr2=nmr;
		}
#ifdef OVERDOUBLE
		d2nmr.x=(double)nmr2;//nmrが2^53を超えている
		d2nmr.y=(double)(((long)nmr2)-(long)d2nmr.x);//nmrが2^63未満であることが条件
		d2tmp=dd_div(d2nmr,d2dnm);
#else
		d2tmp=nn_div((double)nmr2,(double)dnm);
#endif
		if (d2sum1.x>0.0)d2tmp=-d2tmp;//結果的にd2sumの中身が-1～1におさまるよう
		d2sum1=addcab(d2sum1,d2tmp);
		//次のk
		dnm+=dnmadd;
	}
	//長いループ終了
	
	
	//k^-1のところ。答えを適宜反転
	if ((numesign+k%2)%2==1){
		d2sum0=-d2sum0;
		d2sum1=-d2sum1;
	}
	
	
	//double-double精度を2つ使って192bitに結果を収める。上のループと比べると試行回数は１回なので少し非効率でも大丈夫
	ulong ulsum0;//最上位桁
	ulong ulsum1;//中間
	ulong ulsum2;//最下位桁
	//ここがすごい長い！！！！！
	dd2_to_ulong3(d2sum0,d2sum1,&ulsum0,&ulsum1,&ulsum2);
	//256threadまとめる。正しい値をもっているのはlocalid=0のthreadだけ
	__local ulong p[128*3];
	shared_reduction_ulong3(&ulsum0,&ulsum1,&ulsum2,p);
	//グローバルメモリに加算書き込み
	ulong3GlobalADD(ulsum0,ulsum1,ulsum2,bigSum);
}


/////////////////////////64bitバージョン　ルーチンここまで//////////////////////



















//メイン計算のkループの後の数ループ分計算 double-double版
//面倒なので1*1スレッド動作
//あとdouble型を超える分母でもいいように書いてある
__kernel void Sglobal_after(__global double2 *bigSum,const ulong d,const long numesign,const ulong den0,const ulong den1) {
	ulong dnm;//分母
	//ulong nmr;//分子
	double2 sum=0;
	double2 d2tmp;
	double2 d2dnm;
	double dnmr=1.0;
	for(ulong i=0;i<10;i++)
	{
		dnm=den0*(d+i)+den1;
		d2dnm.x=(double)dnm;
		d2dnm.y=(double)((long)dnm-(long)d2dnm.x);
		d2tmp=nd_div(dnmr,d2dnm);
		if ((d+i)%2==1)
		{
			d2tmp=-d2tmp;
		}
		sum=addcab(sum,d2tmp);
		dnmr/=1024.0;
	}
	
	if ((numesign+2)%2==1){
		sum.x=-sum.x;
		sum.y=-sum.y;
	}
	bigSum[0]=addcab(bigSum[0],sum);
}




//メイン計算のkループの後の数ループ分計算
//192bit版
//面倒なので1*1スレッド動作
//あとdouble型を超える分母でもいいように書いてある
__kernel void Sglobal_after_192(__global ulong *bigSum,const ulong d,const long numesign,const ulong den0,const ulong den1) {
	ulong dnm;//分母
	ulong nmr;//分子
	double2 sum0=0;
	double2 sum1=0;
	double2 d2tmp;
	double2 d2dnm;
	double2 d2nmr;
	double dnmr0=1.0;//分子
	double dnmr1=79228162514264337593543950336.0;//2^96
	
	for(ulong i=0;i<19;i++){
		dnmr0/=1024.0;
		dnmr1/=1024.0;
	}

	long i=19;
	//まず上位桁のsum
	for(;i>=0;i--)
	{
		dnm=den0*(d+(ulong)i)+den1;
		d2dnm.x=(double)dnm;
		d2dnm.y=(double)((long)dnm-(long)d2dnm.x);
		d2tmp=nd_div(dnmr0,d2dnm);
		if ((d+(ulong)i)%2==1)
		{
			d2tmp=-d2tmp;
		}
		sum0=addcab(sum0,d2tmp);
		dnmr0*=1024.0;
	}

	
	//下位桁のsum
	for(i=19;i>=10;i--)
	{
		dnm=den0*(d+(ulong)i)+den1;
		d2dnm.x=(double)dnm;
		d2dnm.y=(double)((long)dnm-(long)d2dnm.x);
		d2tmp=nd_div(dnmr1,d2dnm);
		if ((d+(ulong)i)%2==1)
		{
			d2tmp=-d2tmp;
		}
		sum1=addcab(sum1,d2tmp);
		dnmr1*=1024.0;
	}
	//これでdnmr1==64/1024の時を計算して今dnmr1==64
	//今i==9
	for(;i>=0;i--)
	{
		dnm=den0*(d+(ulong)i)+den1;
		if (dnm>(ulong)4294967296){//64bitで考慮する場合
			ulong dnminv=modinv64(dnm);//モンゴメリ乗算で必要
			ulong log2dnm=64-clz(dnm);//モンゴメリ乗算で必要
			double dr1=1.0*(double)((ulong)1<<log2dnm)*((ulong)1<<log2dnm);
			d2dnm.x=(double)dnm;
			d2dnm.y=(double)((long)dnm-(long)d2dnm.x);
			double2 d2rev_dnm=nd_div(dr1,d2dnm);//dnmの逆数を計算、dd精度
			ulong rev_dnm=(long)(d2rev_dnm.x)+(long)(d2rev_dnm.y);//モンゴメリ乗算で必要
			ulong r1=((ulong)18446744073709551615)%dnm+(ulong)1;
			//if (r1==dnm)r1=0;よく考えたらこれは必要ない dnmは奇数のため
			ulong r2=ABmodC64v3(r1,r1,dnm,rev_dnm,log2dnm);
			//ここまでが初期値生成
			
			//べき剰余
			nmr=ExpMod64v4(9-i,dnm,dnminv,r2);
			nmr=ABmodC64v3(nmr,64,dnm,rev_dnm,log2dnm);
			d2nmr.x=(double)nmr;//nmrが2^53を超えている
			d2nmr.y=(double)(((long)nmr)-(long)d2nmr.x);//nmrが2^63未満であることが条件
			d2tmp=dd_div(d2nmr,d2dnm);
		}else{//32bitにおさまる場合
			nmr=64%dnm;
			for(int j=0;j<9-i;j++){
				nmr=(nmr*1024)%dnm;
			}
			d2tmp=nn_div((double)nmr,(double)dnm);
		}
		
		if ((d+(ulong)i)%2==1)
		{
			d2tmp=-d2tmp;
		}
		
		sum1=addcab(sum1,d2tmp);
		sumfix2(&sum1);
	}
	
	if (numesign==1){
		sum0=-sum0;
		sum1=-sum1;
	}
	
	//double-doubleを2つ使ってulong3つにまとめて結果を加算して代入
	ulong ulsum0;//最上位桁
	ulong ulsum1;//中間
	ulong ulsum2;//最下位桁
	dd2_to_ulong3(sum0,sum1,&ulsum0,&ulsum1,&ulsum2);
	//グローバルメモリに加算書き込み
	ulong3GlobalADD(ulsum0,ulsum1,ulsum2,bigSum);
}
















/////////////////////////////////////////////////global memory内の合計/////////////////////////////////////
//最後のdd加算リダクションlocal_work_size=256固定
//66536→256
//256→1にまとめる
__kernel void Ssum(__global const double2 *bigSum,__global double2 *smallSum) {
	__local double2 p[256];
	uint lidx=get_local_id(0);
	uint gridx=get_group_id(0);
	p[lidx]=bigSum[gridx*256+lidx];
	double2 sum;
	for(uint i=128;i>0;i/=2)
	{
		barrier(CLK_LOCAL_MEM_FENCE);
		if (lidx<i){
			sum=addcab(p[lidx],p[lidx+i]);
			sumfix2(&sum);
			p[lidx]=sum;
		}
	}
	
	if (lidx==0){
		smallSum[gridx]=p[0];
	}
}



//最後のdd加算リダクションlocal_work_size=256固定
//66536→256
//256→1にまとめる
__kernel void Ssum_192(__global const ulong *bigSum,__global ulong *smallSum) {	
	ulong ulsum2,ulsum1,ulsum0;
	ulsum0=bigSum[get_global_id(0)*3+0];
	ulsum1=bigSum[get_global_id(0)*3+1];
	ulsum2=bigSum[get_global_id(0)*3+2];
	
	//256threadまとめる。正しい値をもっているのはlocalid=0のthreadだけ
	__local ulong p[128*3];
	shared_reduction_ulong3(&ulsum0,&ulsum1,&ulsum2,p);
	//グローバルメモリに書き込み
	if (get_local_id(0)==0){
		smallSum[get_group_id(0)*3+0]=ulsum0;
		smallSum[get_group_id(0)*3+1]=ulsum1;
		smallSum[get_group_id(0)*3+2]=ulsum2;
	}
}
/////////////////////////////////////////////////global memory内の合計ここまで/////////////////////////////////////




/////////////////////////////////////////////////////7つのSの小数点をまとめるやつ///////////////////////////////////
//1つの項の答えがbigSumMem[0]に入っている。それをdev_ansに加算
//1*1 block*grid
__kernel void Sum7(__global double2 *dev_ans,__global double2 *bigSumMem,const ulong d_numer)
{
	double2 d2a;
	double2 d2b;
	d2a.x=bigSumMem[0].x;
	d2a.y=bigSumMem[0].y;
	
	//d2aをまずは0-1に収める
	if (d2a.x<0.0){
		d2b.x=1.0;
		d2b.y=0.0;
		d2a=addcab(d2a,d2b);
	}
	
	//d2aに分子をかける
	d2a.x*=(double)d_numer;
	d2a.y*=(double)d_numer;
	
	//d2aの小数だけ抽出
	d2b.x=trunc(d2a.x);
	d2b.y=0.0;
	d2a=subcab(d2a,d2b);
	
	bigSumMem[0]=d2a;//必須ではない
	
	//答えに加算
	double2 sum=addcab(dev_ans[0],d2a);
	sumfix(&sum);
	dev_ans[0]=sum;
}



//7つのSの小数点をまとめるやつ
//1*1 block*grid
__kernel void Sum7_192(__global ulong *dev_ans,__global ulong *bigSum,const ulong d_numer)
{
	ulong dmy0=bigSum[0];
	ulong dmy1=bigSum[1];
	ulong dmy2=bigSum[2];
	ulong sht=0;
	if (d_numer==4)sht=2;
	if (d_numer==32)sht=5;
	if (d_numer==64)sht=6;
	if (d_numer==256)sht=8;
	if (sht!=0){
		ulong tmp2,tmp1;
		tmp2=dmy2>>((ulong)64-sht);
		dmy2<<=sht;
		tmp1=dmy1>>((ulong)64-sht);
		dmy1<<=sht;
		dmy1+=tmp2;
		dmy0<<=sht;
		dmy0+=tmp1;
	}
	bigSum[0]=dmy0;
	bigSum[1]=dmy1;
	bigSum[2]=dmy2;
	
	ulong ulsum0=dev_ans[0];
	ulong ulsum1=dev_ans[1];
	ulong ulsum2=dev_ans[2];
	
	ulsum2+=dmy2;
	if (ulsum2<dmy2){
		dmy1++;
		if (dmy1==0)dmy0++;
	}
	ulsum1+=dmy1;
	if (ulsum1<dmy1)dmy0++;
	ulsum0+=dmy0;
	dev_ans[0]=ulsum0;
	dev_ans[1]=ulsum1;
	dev_ans[2]=ulsum2;
}




__kernel void FillBuffer4(__global uint *A,const uint parameta,const uint offset)
{
	A[offset+get_global_id(0)]=parameta;
}


__kernel void FillBuffer8(__global ulong *A,const ulong parameta,const uint offset)
{
	A[offset+get_global_id(0)]=parameta;
}











/*
__kernel void TEST(__global double2 *buffe,__global ulong *bout)
{
}
*/
