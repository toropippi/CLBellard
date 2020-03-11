//#pragma OPENCL EXTENSION cl_khr_fp64 : enable
//#pragma OPENCL EXTENSION cl_khr_int64_base_atomics : enable

double2 twosum(double2 a)
{
	double x = (a.x + a.y);
	double tmp= (x - a.x);
	double y = (a.x - (x - tmp)) + (a.y - tmp);
	double2 outd;
	outd.x=x;
	outd.y=y;
	return outd;
}

double2 dsplit(double a)
{
	double tmp = (a * 134217729.0);
	double x = (tmp - (tmp - a));
	double y = (a - x);
	double2 outd;
	outd.x=x;
	outd.y=y;
	return outd;
}

double2 twoproduct(double2 a)
{
	double x = a.x * a.y;
#ifdef IntelGPU
	if (x>99991999195818789123.11)x=(1.1*a.x+0.234) / (4.11+a.y);//コンパイラによる過剰な最適化の防止の呪文
#endif
	double2 ca = dsplit(a.x);
	double2 cb = dsplit(a.y);
	double y = (((ca.x * cb.x - x) + ca.y * cb.x) + ca.x * cb.y) + ca.y * cb.y;
	double2 outd;
	outd.x=x;
	outd.y=y;
	return outd;
}

double2 addcab(double2 a,double2 b)
{
	double2 ddtmp;
	ddtmp.x=a.x;
	ddtmp.y=b.x;
	double2 cz = twosum(ddtmp);
	cz.y = cz.y + a.y + b.y;
	return twosum(cz);
}

double2 subcab(double2 a,double2 b)
{
	double2 ddtmp;
	ddtmp.x=a.x;
	ddtmp.y=-b.x;
	double2 cz = twosum(ddtmp);
	cz.y = cz.y + a.y - b.y;
	return twosum(cz);
}

double2 ddmulcab(double2 a,double2 b)
{
	double2 ddtmp;
	ddtmp.x=a.x;
	ddtmp.y=b.x;
	double2 cz = twoproduct(ddtmp);
	cz.y = cz.y + a.x * b.y + a.y * b.x + a.y * b.y;
	return twosum(cz);
}


double2 dnmulcab(double2 a,double b)
{
	double2 ddtmp;
	ddtmp.x=a.x;
	ddtmp.y=b;
	double2 cz = twoproduct(ddtmp);
	cz.y = cz.y + a.y * b;
	return twosum(cz);
}

double2 nnmulcab(double a,double b)
{
	double2 ddtmp;
	ddtmp.x=a;
	ddtmp.y=b;
	double2 cz = twoproduct(ddtmp);
	return cz;
}


double2 dd_div(double2 x,double2 y)
{
	double z1 = x.x / y.x;
	double2 ddtmp;ddtmp.x=-z1;ddtmp.y=y.x;
	double2 cz = twoproduct(ddtmp);
	double z2 = ((((cz.x + x.x) - z1 * y.y) + x.y) + cz.y) / y.x;
	ddtmp.x=z1;
	ddtmp.y=z2;
	return twosum(ddtmp);
}


double2 dn_div(double2 x,double y)
{
	double z1 = x.x / y;
	double2 ddtmp;ddtmp.x=-z1;ddtmp.y=y;
	double2 cz = twoproduct(ddtmp);
	double z2 = (((cz.x + x.x) + x.y) + cz.y) / y;
	ddtmp.x=z1;
	ddtmp.y=z2;
	return twosum(ddtmp);
}

double2 nd_div(double x,double2 y)
{
	double z1 = x / y.x;
	double2 ddtmp;ddtmp.x=-z1;ddtmp.y=y.x;
	double2 cz = twoproduct(ddtmp);
	double z2 = (((cz.x + x) - z1 * y.y) + cz.y) / y.x;
	ddtmp.x=z1;
	ddtmp.y=z2;
	return twosum(ddtmp);
}


double2 nn_div(double x,double y)
{
	double z1 = x / y;
	double2 ddtmp;ddtmp.x=-z1;ddtmp.y=y;
	double2 cz = twoproduct(ddtmp);
	double z2 = ((cz.x + x) + cz.y) / y;
	ddtmp.x=z1;
	ddtmp.y=z2;
	return twosum(ddtmp);
}



/*
//dd x :log 2底のxを返す
double2 dd_log2(ulong ulx,__global double2 *revarray)
{
	double dx=(double)ulx;
	int iexp;
	double dxc=frexp(dx, &iexp);
	if (dxc<0.666)
	{
		dxc*=2.0;
		iexp--;
	}

	//これのlogをマクローリン展開の形から計算する
	double xb = dxc-1.0;
	double2 outx;
	outx.x=0;outx.y=0;

	//ループ回数を計算
	float xbhi=fanmr((float)xb);
	if (xbhi<0.001f)
	  xbhi=0.001f;
	int n=(int)(-(107.0f*0.693147180559945309417232f)/log(xbhi))+3;
	if (n<2)
	  n=2;

	for(int i=n;i>=0;i--){
		outx = subcab(revarray[i],outx);
		outx = dnmulcab(outx,xb);
	}
	double2 log2e;
	log2e.x=12994641697113596.0/9007199254740992.0;
	log2e.y=1651415998432073.0/9007199254740992.0/9007199254740992.0;
	outx = ddmulcab(outx,log2e);
	double2 ddmpt;ddmpt.x=(double)iexp;ddmpt.y=0;
	outx = addcab(outx,ddmpt);//outx+=dd((double)keta,0);
	return outx;
}
*/































/*
//1:only c >= (1<<32)
//2:only a*b<c*c
//return a*b mod c
ulong ABmodC64(ulong a,ulong b,ulong c)
{
	ulong xc=(((ulong)1<<(ulong)63)%c)*(ulong)2;
	xc-=(xc>=c)*c;
	ulong anslo=a*b; // (64bit)
	ulong anshi=mul_hi(a,b); // (64bit)
	ulong c1=c>>(ulong)32; // (32bit)
	ulong c2=c%((ulong)1<<(ulong)32); // ull c2=c&0x00000000FFFFFFFF; 
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
	ulong resans=anslo%c;
	if (anshi>((ulong)1<<(ulong)63))
	{
		if (anslo!=(ulong)0)anshi++;
		resans=(c*(ulong)2-resans-((ulong)0-anshi)*xc);
		if (resans>=c)resans-=c;
		if (resans>=c)resans-=c;
	}
	return resans;
}
*/






uint modinv32(ulong m)
{
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
}

ulong modinv64(ulong m)
{
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
}









//除数決め打ちなのを利用して乗算とビットシフトだけに書き換えたバージョン 自作
ulong ABmodC64v3(ulong a,ulong b,ulong MODP,ulong rMODP,ulong MODLOG)
{
	ulong blo=a*b;
	ulong bhi=mul_hi(a,b);
	ulong b1=(bhi<<((ulong)64-MODLOG))|(blo>>MODLOG);
	ulong b2lo=b1*rMODP;
	ulong b2hi=mul_hi(b1,rMODP);
	ulong b2=(b2hi<<((ulong)64-MODLOG))|(b2lo>>MODLOG);
	ulong b2alo=b2*MODP;
	ulong b2ahi=mul_hi(b2,MODP);
	
	bhi-=b2ahi;
	if (blo<b2alo)bhi-=1;
	blo-=b2alo;
	if (bhi==(ulong)18446744073709551615){
		bhi=0;
		blo+=MODP;
	}
	
	//この時点でbは最大4MODP-1
	if (bhi>0){
		
		if (blo<MODP)bhi-=1;
		blo-=MODP;
	}
	//この時点でbの最大は4MODP-1
	if (blo>=MODP){
		blo-=MODP;
	}
	//この時点でbの最大は3MODP-1
	if (blo>=MODP){
		blo-=MODP;
	}
	
	//この時点でbの最大は2MODP-1
	if (blo>=MODP){
		blo-=MODP;
	}
	
	return blo;
}






ulong ExpMod32(ulong a,ulong n,ulong c){
	ulong ans=1;
	for(int i=0;i<64;i++){
		if (n%2==1){
			ans=(ans*a)%c;
		}
		a=a*a%c;
		n/=2;
		if (n==0)break;
	}
	return ans;
}

/*
ulong ExpMod64(ulong a,ulong n,ulong c){
	ulong ans=1;
	for(int i=0;i<64;i++){
		if (n%(ulong)2==(ulong)1){
			ans=ABmodC64(ans,a,c);
		}
		a=ABmodC64(a,a,c);
		n/=(ulong)2;
		if (n==(ulong)0)break;
	}
	return ans;
}
*/

//a=1024の冪剰余に固定、最適化
ulong ExpMod64v3(ulong n,ulong c,ulong rc,ulong log2c){
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
	a=ABmodC64v3(1048576,1048576,c,rc,log2c);//1048576
	n/=2;
	//loop1ここまで
	
	for(int i=0;i<62;i++){
		if (n%2==1){
			ans=ABmodC64v3(ans,a,c,rc,log2c);
		}
		if (n<=1)break;
		a=ABmodC64v3(a,a,c,rc,log2c);
		n/=2;
	}
	return ans;
}




//モンゴメリリダクション32bit版
uint MR32(uint xlo,uint xhi,uint inv,uint c)
{
	uint xinv=xlo*inv;
	uint ret=mul_hi(xinv,c);
	if (xlo!=0)ret++;//分かりにくいが、xinv*c+xloは必ずRで割り切れるので
	//ret+=xhi;//これはオーバーフローするかもしれないので以下4行
	uint ans=ret+xhi;
	if ((ans>=c)|(ans<xhi)){
		ans-=c;
	}
	return ans;
}


//a=1024のn乗MOD c、モンゴメリ乗算32bit、最適化
uint ExpMod32v4(ulong n,uint c,uint inv,uint R2){
	//uint a=1024;
	uint p=MR32(R2<<10,R2>>22,inv,c);
	uint x=MR32(R2,0,inv,c);
	for(int i=0;i<64;i++){
		if (n%(ulong)2==(ulong)1){
			x=MR32(x*p,mul_hi(x,p),inv,c);
		}
		p=MR32(p*p,mul_hi(p,p),inv,c);
		n/=(ulong)2;
		if (n==(ulong)0)break;
	}
	return MR32(x,0,inv,c);
}



//モンゴメリリダクション
ulong MR64(ulong xlo,ulong xhi,ulong inv,ulong c)
{
	ulong xinv=xlo*inv;
	ulong ret=mul_hi(xinv,c);
	if (xlo!=0)ret++;//分かりにくいが、xinv*c+xloは必ずRで割り切れるので
	//ret+=xhi;//これはオーバーフローするかもしれないので以下4行
	ulong ans=ret+xhi;
	if ((ans>=c)|(ans<xhi)){//ans==cの場合も同時に処理
		ans-=c;
	}
	return ans;

}


//a=1024のn乗MOD c、モンゴメリ乗算、最適化
ulong ExpMod64v4(ulong n,ulong c,ulong inv,ulong R2){
	ulong a=1024;
	ulong p=MR64(R2<<(ulong)10,R2>>(ulong)54,inv,c);
	ulong x=MR64(R2,0,inv,c);
	for(int i=0;i<64;i++){
		if (n%(ulong)2==(ulong)1){
			x=MR64(x*p,mul_hi(x,p),inv,c);
		}
		p=MR64(p*p,mul_hi(p,p),inv,c);
		n/=(ulong)2;
		if (n==(ulong)0)break;
	}
	return MR64(x,0,inv,c);
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
		double2 ddtmp;ddtmp.x=(*sum).x;ddtmp.y=-1.0;
		ddtmp=twosum(ddtmp);
		ddtmp.y+=(*sum).y;
		*sum=twosum(ddtmp);
	}
}



//double-double精度を2つ使って192bitに結果を収める。上のループと比べると試行回数は１回なので少し非効率でも大丈夫
void dd2TOulong3(double2 d2sum0,double2 d2sum1,ulong *outul0,ulong *outul1,ulong *outul2){
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



//1threadあたりulongを3つもっているので256threadで全部結果をまとめて繰り上がり処理して結果をグローバルメモリに書き込み
void Ulong3BlockSum(ulong* ulsum0_,ulong* ulsum1_,ulong* ulsum2_,__local ulong* p){
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
void Ulong3GlobalADD(ulong ulsum0,ulong ulsum1,ulong ulsum2,__global ulong* BigSUM)
{
	if (get_local_id(0)==0){
		ulong dmy0=BigSUM[get_group_id(0)*3+0];
		ulong dmy1=BigSUM[get_group_id(0)*3+1];
		ulong dmy2=BigSUM[get_group_id(0)*3+2];
		ulsum2+=dmy2;
		if (ulsum2<dmy2){
			dmy1++;
			if (dmy1==0)dmy0++;
		}
		ulsum1+=dmy1;
		if (ulsum1<dmy1)dmy0++;
		ulsum0+=dmy0;
		BigSUM[get_group_id(0)*3+0]=ulsum0;
		BigSUM[get_group_id(0)*3+1]=ulsum1;
		BigSUM[get_group_id(0)*3+2]=ulsum2;
	}
}




































//メイン計算部分32bit
//local_work_size=256に固定、最後にshared memoryでリダクションして結果をBigSUMに格納
__kernel void Sglobal32(__global double2 *BigSUM,ulong offset,ulong d,ulong k_max,ulong nume,long numesign,ulong den0,ulong den1) {
	ulong gsize=get_global_size(0);
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
	uint lidx=get_local_id(0);
	p[lidx]=sum;
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
		sum=addcab(BigSUM[get_group_id(0)],p[0]);
		sumfix2(&sum);
		BigSUM[get_group_id(0)]=sum;
	}
}


//メイン計算部分モンゴメリ乗算版32bit
//local_work_size=256に固定、最後にshared memoryでリダクションして結果をBigSUMに格納
__kernel void Sglobal32mtg(__global double2 *BigSUM,ulong offset,ulong d,ulong k_max,ulong nume,long numesign,ulong den0,ulong den1) {
	ulong gsize=get_global_size(0);
	ulong idx = get_global_id(0);
	ulong k=idx+offset;
	ulong dnm=den0*k+den1;//分母
	uint nmr;//分子
	double2 sum=0.0;
	double2 d2tmp;
	uint dnminv;
	uint R2;
	for(;k<k_max;k+=gsize)
	{
		dnminv=modinv32((uint)dnm);
		R2=(uint)(((ulong)18446744073709551615)%(dnm))+1;
		if (R2==(uint)dnm)R2=0;
		nmr=ExpMod32v4(d-(ulong)k,(uint)dnm,dnminv,R2);
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
	uint lidx=get_local_id(0);
	p[lidx]=sum;
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
		sum=addcab(BigSUM[get_group_id(0)],p[0]);
		sumfix2(&sum);
		BigSUM[get_group_id(0)]=sum;
	}
}





//メイン計算部分モンゴメリ乗算版32bit、ulong3に結果まとめるやつ
//local_work_size=256に固定、最後にshared memoryでリダクションして結果をBigSUMに格納
__kernel void Sglobal32mtg_192(__global ulong *BigSUM,ulong offset,ulong d,ulong k_max,ulong nume,long numesign,ulong den0,ulong den1) {
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
	uint R2;
	for(;k<k_max;k+=gsize)
	{
		dnminv=modinv32((uint)dnm);
		R2=(uint)(((ulong)18446744073709551615)%(dnm))+1;
		if (R2==(uint)dnm)R2=0;
		nmr=ExpMod32v4(d-(ulong)k,(uint)dnm,dnminv,R2);
		if (sum0.x>0.0){//結果的にsumの中身が-1～1におさまるよう
			nmr2=dnm-(ulong)nmr;
		}else{
			nmr2=(ulong)nmr;
		}
		d2tmp=nn_div((double)nmr2,(double)dnm);
		if (sum0.x>0.0)//結果的にsumの中身が-1～1におさまるよう
			d2tmp=-d2tmp;
		sum0=addcab(sum0,d2tmp);

		//次に(nmr*(2^96)%dnm)/dnmを求める
		nmr2=((ulong)nmr*(ulong)R2)%dnm;
		nmr2=nmr2*((ulong)4294967296)%dnm;
		if (sum1.x>0.0){//結果的にsumの中身が-1～1におさまるよう
			nmr2=dnm-nmr2;
		}
		d2tmp=nn_div((double)nmr2,(double)dnm);
		if (sum1.x>0.0)//結果的にsumの中身が-1～1におさまるよう
			d2tmp=-d2tmp;
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
	dd2TOulong3(sum0,sum1,&ulsum0,&ulsum1,&ulsum2);
	//256threadまとめる。正しい値をもっているのはlocalid=0のthreadだけ
	__local ulong p[128*3];
	Ulong3BlockSum(&ulsum0,&ulsum1,&ulsum2,p);
	//グローバルメモリに加算書き込み
	Ulong3GlobalADD(ulsum0,ulsum1,ulsum2,BigSUM);
}








































//メイン計算部分、64bit
//local_work_size=256に固定、最後にshared memoryでリダクションして結果をBigSUMに格納
__kernel void Sglobal64(__global double2 *BigSUM,ulong offset,ulong d,ulong k_max,ulong nume,long numesign,ulong den0,ulong den1) {
	ulong gsize=get_global_size(0);
	ulong idx = get_global_id(0);
	ulong k=idx+offset;
	ulong dnm=den0*k+den1;//分母
	ulong dnmadd=gsize*den0;
	ulong nmr;//分子
	double2 sum=0.0;
	double2 d2tmp;
	ulong rc;
	ulong log2c;
	ulong uiclz=clz(dnm);
	double dr1;
	log2c=64-uiclz;
	dr1=1.0*(double)((ulong)1<<log2c)*((ulong)1<<log2c);
	for(;k<k_max;k+=gsize)
	{
		if (uiclz!=clz(dnm)){
			uiclz--;
			log2c++;
			dr1*=4.0;
		}
		rc=(ulong)(dr1/(double)dnm);
		nmr=ExpMod64v3(d-k,dnm,rc,log2c);
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
	uint lidx=get_local_id(0);
	p[lidx]=sum;
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
		sum=addcab(BigSUM[get_group_id(0)],p[0]);
		sumfix2(&sum);
		BigSUM[get_group_id(0)]=sum;
	}
}



//メイン計算部分モンゴメリ乗算版64bit
//local_work_size=256に固定、最後にshared memoryでリダクションして結果をBigSUMに格納
__kernel void Sglobal64mtg(__global double2 *BigSUM,ulong offset,ulong d,ulong k_max,ulong nume,long numesign,ulong den0,ulong den1) {
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
	double2 rdeno;
	ulong dnminv;
	ulong R2;
	ulong log2c;
	double dr1;
	ulong rc;
	
	for(;k<k_max;k+=gsize)
	{
		dnminv=modinv64(dnm);
		log2c=64-clz(dnm);
		dr1=1.0*(double)((ulong)1<<log2c)*((ulong)1<<log2c);
#ifdef OVERDOUBLE
		d2dnm.x=(double)dnm;
		d2dnm.y=(double)((long)dnm-(long)d2dnm.x);
		rdeno=nd_div(dr1,d2dnm);//dnmの逆数を計算、dd精度
		rc=(long)(rdeno.x)+(long)(rdeno.y);//モンゴメリ乗算で必要
#else
		//rdeno=nn_div();//dnmの逆数dd精度
		rc=(ulong)(dr1/(double)dnm);//モンゴメリ乗算で必要
#endif
		R2=((ulong)18446744073709551615)%dnm+(ulong)1;
		//if (R2==dnm)R2=0;//いらない
		R2=ABmodC64v3(R2,R2,dnm,rc,log2c);
		nmr=ExpMod64v4(d-k,dnm,dnminv,R2);
		
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
		if (sum.x>0.0){
			d2tmp=-d2tmp;
		}
		sum=addcab(sum,d2tmp);
		//sumfix(&sum);
		dnm+=dnmadd;
	}
	
	if ((numesign+k%2)%2==1){
		sum=-sum;
	}
	
	//シェアードメモリ内でdd加算して結果をglobalメモリに加算出力
	__local double2 p[256];
	uint lidx=get_local_id(0);
	p[lidx]=sum;
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
		sum=addcab(BigSUM[get_group_id(0)],p[0]);
		sumfix2(&sum);
		BigSUM[get_group_id(0)]=sum;
	}
}







//メイン計算部分モンゴメリ乗算版64bit、2つのdouble-double(105bit*2)を64bit整数*3にまとめる
//local_work_size=256に固定、最後にshared memoryでリダクションして結果をBigSUMに格納
__kernel void Sglobal64mtg_192(__global ulong *BigSUM,ulong offset,ulong d,ulong k_max,ulong nume,long numesign,ulong den0,ulong den1) {
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
	double2 rdeno;
	double2 d2tmp;
	ulong dnminv;
	ulong R2;
	ulong R1;
	ulong log2c;
	double dr1;
	ulong rc;
	
	for(;k<k_max;k+=gsize)
	{
		dnminv=modinv64(dnm);//モンゴメリ乗算で必要
		log2c=64-clz(dnm);//モンゴメリ乗算で必要
		dr1=1.0*(double)((ulong)1<<log2c)*((ulong)1<<log2c);
#ifdef OVERDOUBLE
		d2dnm.x=(double)dnm;
		d2dnm.y=(double)((long)dnm-(long)d2dnm.x);
		rdeno=nd_div(dr1,d2dnm);//dnmの逆数を計算、dd精度
		rc=(long)(rdeno.x)+(long)(rdeno.y);//モンゴメリ乗算で必要
#else
		//rdeno=nn_div();//dnmの逆数dd精度
		rc=(ulong)(dr1/(double)dnm);//モンゴメリ乗算で必要
#endif
		R1=((ulong)18446744073709551615)%dnm+(ulong)1;
		//if (R1==dnm)R1=0;よく考えたらこれは必要ない dnmは奇数のため
		R2=ABmodC64v3(R1,R1,dnm,rc,log2c);
		//ここまでが初期値生成
		
		
		//べき剰余
		nmr=ExpMod64v4(d-k,dnm,dnminv,R2);
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
		if (d2sum0.x>0.0)//結果的にd2sumの中身が-1～1におさまるよう
			d2tmp=-d2tmp;
		d2sum0=addcab(d2sum0,d2tmp);
		//sumfix(&d2sum0);
		
		
		//次に(nmr*(2^96)%dnm)/dnmを求める
		nmr=ABmodC64v3(nmr,R1,dnm,rc,log2c);
		nmr=ABmodC64v3(nmr,(ulong)4294967296,dnm,rc,log2c);
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
		if (d2sum1.x>0.0)//結果的にd2sumの中身が-1～1におさまるよう
			d2tmp=-d2tmp;
		d2sum1=addcab(d2sum1,d2tmp);
		//sumfix(&d2sum1);
		
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
	dd2TOulong3(d2sum0,d2sum1,&ulsum0,&ulsum1,&ulsum2);
	//256threadまとめる。正しい値をもっているのはlocalid=0のthreadだけ
	__local ulong p[128*3];
	Ulong3BlockSum(&ulsum0,&ulsum1,&ulsum2,p);
	//グローバルメモリに加算書き込み
	Ulong3GlobalADD(ulsum0,ulsum1,ulsum2,BigSUM);
}






















//メイン計算のkループの後の数ループ分計算
//面倒なので1*1スレッド動作
//あとdouble型を超える分母でもいいように書いてある
__kernel void Sglobal_after(__global double2 *BigSUM,ulong d,ulong nume,long numesign,ulong den0,ulong den1) {
	ulong dnm;//分母
	//ulong nmr;//分子
	double2 sum;sum.x=0;sum.y=0;
	double2 d2tmp;
	double2 d2dnm;
	double db=1.0;
	for(ulong i=0;i<10;i++)
	{
		dnm=den0*(d+i)+den1;
		d2dnm.x=(double)dnm;
		d2dnm.y=(double)((long)dnm-(long)d2dnm.x);
		d2tmp=nd_div(db,d2dnm);
		if ((d+i)%2==1)
		{
			d2tmp=-d2tmp;
		}
		sum=addcab(sum,d2tmp);
		db/=1024.0;
	}
	
	if ((numesign+2)%2==1){
		sum.x=-sum.x;
		sum.y=-sum.y;
	}
	BigSUM[0]=addcab(BigSUM[0],sum);
}




//メイン計算のkループの後の数ループ分計算
//192bit版
//面倒なので1*1スレッド動作
//あとdouble型を超える分母でもいいように書いてある
__kernel void Sglobal_after_192(__global ulong *BigSUM,ulong d,ulong nume,long numesign,ulong den0,ulong den1) {
	ulong dnm;//分母
	ulong nmr;//分子
	double2 sum0=0;
	double2 sum1=0;
	double2 d2tmp;
	double2 d2dnm;
	double2 d2nmr;
	double db0=1.0;//分子
	double db1=79228162514264337593543950336.0;//2^96
	
	for(ulong i=0;i<19;i++){
		db0/=1024.0;
		db1/=1024.0;
	}

	long i=19;
	//まず上位桁のsum
	for(;i>=0;i--)
	{
		dnm=den0*(d+(ulong)i)+den1;
		d2dnm.x=(double)dnm;
		d2dnm.y=(double)((long)dnm-(long)d2dnm.x);
		d2tmp=nd_div(db0,d2dnm);
		if ((d+(ulong)i)%2==1)
		{
			d2tmp=-d2tmp;
		}
		sum0=addcab(sum0,d2tmp);
		db0*=1024.0;
	}

	
	//下位桁のsum
	for(i=19;i>=10;i--)
	{
		dnm=den0*(d+(ulong)i)+den1;
		d2dnm.x=(double)dnm;
		d2dnm.y=(double)((long)dnm-(long)d2dnm.x);
		d2tmp=nd_div(db1,d2dnm);
		if ((d+(ulong)i)%2==1)
		{
			d2tmp=-d2tmp;
		}
		sum1=addcab(sum1,d2tmp);
		db1*=1024.0;
	}
	//これでdb1==64/1024の時を計算して今db1==64
	//今i==9
	for(;i>=0;i--)
	{
		dnm=den0*(d+(ulong)i)+den1;
		if (dnm>(ulong)4294967296){//64bitで考慮する場合
						ulong dnminv=modinv64(dnm);//モンゴメリ乗算で必要
						ulong log2c=64-clz(dnm);//モンゴメリ乗算で必要
						double dr1=1.0*(double)((ulong)1<<log2c)*((ulong)1<<log2c);
						d2dnm.x=(double)dnm;
						d2dnm.y=(double)((long)dnm-(long)d2dnm.x);
						double2 rdeno=nd_div(dr1,d2dnm);//dnmの逆数を計算、dd精度
						ulong rc=(long)(rdeno.x)+(long)(rdeno.y);//モンゴメリ乗算で必要
						ulong R1=((ulong)18446744073709551615)%dnm+(ulong)1;
						//if (R1==dnm)R1=0;よく考えたらこれは必要ない dnmは奇数のため
						ulong R2=ABmodC64v3(R1,R1,dnm,rc,log2c);
						//ここまでが初期値生成
						
						//べき剰余
						nmr=ExpMod64v4(9-i,dnm,dnminv,R2);
						nmr=ABmodC64v3(nmr,64,dnm,rc,log2c);
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
	dd2TOulong3(sum0,sum1,&ulsum0,&ulsum1,&ulsum2);
	//グローバルメモリに加算書き込み
	Ulong3GlobalADD(ulsum0,ulsum1,ulsum2,BigSUM);
}










//最後のdd加算リダクションlocal_work_size=256固定
//66536→256
//256→1にまとめる
__kernel void Ssum(__global double2 *BigSUM,__global double2 *SmallSUM) {
	__local double2 p[256];
	uint lidx=get_local_id(0);
	uint gridx=get_group_id(0);
	p[lidx]=BigSUM[gridx*256+lidx];
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
		SmallSUM[gridx]=p[0];
	}
}



//最後のdd加算リダクションlocal_work_size=256固定
//66536→256
//256→1にまとめる
__kernel void Ssum_192(__global ulong *BigSUM,__global ulong *SmallSUM) {	
	ulong ulsum2,ulsum1,ulsum0;
	ulsum0=BigSUM[get_global_id(0)*3+0];
	ulsum1=BigSUM[get_global_id(0)*3+1];
	ulsum2=BigSUM[get_global_id(0)*3+2];
	
	//256threadまとめる。正しい値をもっているのはlocalid=0のthreadだけ
	__local ulong p[128*3];
	Ulong3BlockSum(&ulsum0,&ulsum1,&ulsum2,p);
	//グローバルメモリに書き込み
	if (get_local_id(0)==0){
		SmallSUM[get_group_id(0)*3+0]=ulsum0;
		SmallSUM[get_group_id(0)*3+1]=ulsum1;
		SmallSUM[get_group_id(0)*3+2]=ulsum2;
	}
}





//7つのSの小数点をまとめるやつ
//1*1 block*grid
__kernel void Sum7(__global double2 *dev_ans,__global double2 *bigSumMem,ulong d_numer)
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

	bigSumMem[0]=d2a;
	
	//答えに加算
	double2 sum=addcab(dev_ans[0],d2a);
	sumfix(&sum);
	dev_ans[0]=sum;
}



//7つのSの小数点をまとめるやつ
//1*1 block*grid
__kernel void Sum7_192(__global ulong *dev_ans,__global ulong *BigSUM,ulong d_numer)
{
	ulong dmy0=BigSUM[0];
	ulong dmy1=BigSUM[1];
	ulong dmy2=BigSUM[2];
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
	BigSUM[0]=dmy0;
	BigSUM[1]=dmy1;
	BigSUM[2]=dmy2;

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




__kernel void FillBuffer4(__global uint *A,uint parameta,uint offset)
{
	A[offset+get_global_id(0)]=parameta;
}


__kernel void FillBuffer8(__global ulong *A,ulong parameta,uint offset)
{
	A[offset+get_global_id(0)]=parameta;
}











/*
__kernel void TEST(__global double2 *buffe,__global ulong *bout)
{
	ulong ulsum0,ulsum1;
	bout[2]=0;
}
*/
