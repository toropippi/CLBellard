//残念ながらボツになった関数群

float2 twosum_f(const float2 a)
{
	float x = (a.x + a.y);
	float tmp= (x - a.x);
	float y = (a.x - (x - tmp)) + (a.y - tmp);
	return (float2){x,y};
}

float2 dsplit_f(const float a)
{
	float tmp = (a * 4097.0);
	float x = (tmp - (tmp - a));
	float y = (a - x);
	return (float2){x,y};
}

float2 twoproduct_f(const float2 a)
{
	float x = a.x * a.y;
#ifdef IntelGPU
	if (x>99991999195818789123.11)x=(1.1*a.x+0.234) / (4.11+a.y);//コンパイラによる過剰な最適化の防止の呪文
#endif
	float2 ca = dsplit_f(a.x);
	float2 cb = dsplit_f(a.y);
	float y = (((ca.x * cb.x - x) + ca.y * cb.x) + ca.x * cb.y) + ca.y * cb.y;
	return (float2){x,y};
}

float2 addcab_f(const float2 a,const float2 b)
{
	float2 tmp={a.x,b.x};
	float2 cz = twosum_f(tmp);
	cz.y = cz.y + a.y + b.y;
	return twosum_f(cz);
}

float2 subcab_f(const float2 a,const float2 b)
{
	float2 tmp={a.x,-b.x};
	float2 cz = twosum_f(tmp);
	cz.y = cz.y + a.y - b.y;
	return twosum_f(cz);
}

float2 ffmulcab(const float2 a,const float2 b)
{
	float2 tmp={a.x,b.x};
	float2 cz = twoproduct_f(tmp);
	cz.y = cz.y + a.x * b.y + a.y * b.x + a.y * b.y;
	return twosum_f(cz);
}


float2 fnmulcab(const float2 a,const float b)
{
	float2 tmp={a.x,b};
	float2 cz = twoproduct_f(tmp);
	cz.y = cz.y + a.y * b;
	return twosum_f(cz);
}

float2 nnmulcab_f(const float a,const float b)
{
	float2 tmp={a,b};
	float2 cz = twoproduct_f(tmp);
	return cz;
}


float2 ff_div(const float2 x,const float2 y)
{
	float z1 = x.x / y.x;
	float2 tmp={-z1,y.x};
	float2 cz = twoproduct_f(tmp);
	float z2 = ((((cz.x + x.x) - z1 * y.y) + x.y) + cz.y) / y.x;
	return twosum_f((float2){z1,z2});
}


float2 fn_div(const float2 x,const float y)
{
	float z1 = x.x / y;
	float2 tmp={-z1,y};
	float2 cz = twoproduct_f(tmp);
	float z2 = (((cz.x + x.x) + x.y) + cz.y) / y;
	return twosum_f((float2){z1,z2});
}

float2 nf_div(const float x,const float2 y)
{
	float z1 = x / y.x;
	float2 tmp={-z1,y.x};
	float2 cz = twoproduct_f(tmp);
	float z2 = (((cz.x + x) - z1 * y.y) + cz.y) / y.x;
	return twosum_f((float2){z1,z2});
}


float2 nn_div_f(const float x,const float y)
{
	float z1 = x / y;
	float2 tmp={-z1,y};
	float2 cz = twoproduct_f(tmp);
	float z2 = ((cz.x + x) + cz.y) / y;
	return twosum_f((float2){z1,z2});
}



/*
//dd演算のlog
//dd x :log 2底のxを返す
double2 dd_log2(const ulong ulx,__global const double2 *revarray)
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
//64bit*64bitのfloat実装、遅くてボツになったやつ
float myfloor(float df){
	if (df<1.0)return 0.0;
	if (df<2.0)return 1.0;
	if (df<3.0)return 2.0;
	return 3.0;
}

void mymul64_f(float a2,float a1,float a0,float b2,float b1,float b0,float *outc2,float *outc1,float *outc0){
	float c0,c1,c2,c3,c4;
	c0=a0*b0;
	c1=a1*b0+a0*b1;
	c2=a2*b0+a1*b1+a0*b2;
	c3=a2*b1+a1*b2;
	c4=a2*b2;
	
	//いったんc2を繰り上がり処理する
	float upt=myfloor(c2*0.0000002384185791015625);
	c4+=upt;
	c2-=upt*4194304.0;
	//c0,c2,c4に結果を格納していく
	float tmp=myfloor(c1*0.00048828125);
	c2+=tmp;
	c1-=tmp*2048.0;
	c0+=c1*2048.0;
	tmp=myfloor(c0*0.0000002384185791015625);
	c2+=tmp;
	c0-=tmp*4194304.0;
	
	tmp=myfloor(c3*0.00048828125);
	c4+=tmp;
	c3-=tmp*2048.0;
	c2+=c3*2048.0;
	
	tmp=myfloor(c2*0.0000002384185791015625);
	c4+=tmp;
	c2-=tmp*4194304.0;
	
	*outc2=c4;
	*outc1=c2;
	*outc0=c0;
}


void mymul128_f(ulong a,ulong b,ulong *outhi,ulong *outlo){
	//float1こに11bitいれる
	float a5,a4,a3,a2,a1,a0;
	float b5,b4,b3,b2,b1,b0;
	//a0=a&0b0000000000000000000000000000000000000000000000000000000000000000;
	a0=(float)(a&(ulong)2047);
	a1=(float)(a&(ulong)4192256);
	a2=(float)(a&(ulong)4290772992);
	a3=(float)(a&(ulong)8791798054912);
	a4=(float)(a&(ulong)18005602416459776);
	a5=(float)(a&(ulong)18428729675200069632);
	a1*=0.00048828125;
	a2*=0.00048828125*0.00048828125;
	a3*=0.00048828125*0.00048828125*0.0009765625;
	a4*=0.00048828125*0.00048828125*0.0009765625*0.00048828125;
	a5*=0.00048828125*0.00048828125*0.0009765625*0.00048828125*0.00048828125;
	
	b0=(float)(b&(ulong)2047);
	b1=(float)(b&(ulong)4192256);
	b2=(float)(b&(ulong)4290772992);
	b3=(float)(b&(ulong)8791798054912);
	b4=(float)(b&(ulong)18005602416459776);
	b5=(float)(b&(ulong)18428729675200069632);
	b1*=0.00048828125;
	b2*=0.00048828125*0.00048828125;
	b3*=0.00048828125*0.00048828125*0.0009765625;
	b4*=0.00048828125*0.00048828125*0.0009765625*0.00048828125;
	b5*=0.00048828125*0.00048828125*0.0009765625*0.00048828125*0.00048828125;
	
	
	float c5,c4,c3,c2,c1,c0;
	float cm2,cm1,cm0;
	float cm5,cm4,cm3;
	mymul64_f(a2,a1,a0,b2,b1,b0,&c2,&c1,&c0);
	mymul64_f(a5,a4,a3,b5,b4,b3,&c5,&c4,&c3);
	
	//あえてaとbで符号を変えている。これでKaratsuba計算後、足すだけで良くなる
	//mymul64_f(a5-a2,a4-a1,a3-a0,b2-b5,b1-b4,b0-b3,&cm2,&cm1,&cm0);
	//cm2+=c5+c2;
	//cm1+=c4+c1;
	//cm0+=c3+c0;
	
	mymul64_f(a5,a4,a3,b2,b1,b0,&cm2,&cm1,&cm0);
	mymul64_f(a2,a1,a0,b5,b4,b3,&cm5,&cm4,&cm3);
	cm2+=cm5;
	cm1+=cm4;
	cm0+=cm3;
	
	//あとはうまく足してulongにまとめる
	float tmp;
	*outlo=(ulong)c0;
	tmp=trunc(c1/1024.0);
	c1-=tmp*1024.0;
	cm0+=tmp;
	*outlo+=(ulong)(c1*4194304.0);
	
	tmp=trunc(c2/1024.0);
	c2-=tmp*1024.0;
	cm1+=tmp;
	cm0+=c2*4096.0;
	*outlo+=(ulong)(cm0*4294967296.0);
	
	tmp=trunc(cm1/1024.0);
	cm1-=tmp*1024.0;
	c3+=tmp;
	*outlo+=(ulong)(cm1*18014398509481984.0);
	
	*outhi=(ulong)c3;
	*outhi+=(ulong)(c4*4194304.0);
	*outhi+=(ulong)(c5*17592186044416.0);
	cm2*=4096.0;
	if (cm2<0.0){
		*outhi-=(ulong)(-cm2);
	}else{
		*outhi+=(ulong)(cm2);
	}
	
}


*/




//(a1a0)*(b1b0)
//32bit*32bit=64bit
void mymul64(uint a1,uint a0,uint b1,uint b0,uint *outhi,uint *outlo){
	
	//案1
	uint ab00=a0*b0;
	uint ab11=a1*b1;
	uint ab01=a0*b1;
	uint ab10=a1*b0;
	
	uint tmp=ab01+ab10;
	if (tmp<ab01)ab11+=65536;
	
	
	*outlo=ab00+(tmp%65536)*65536;
	if (*outlo<ab00){
		ab11++;
	}
	
	*outhi=ab11+tmp/65536;
	
}

void mymul128(ulong a,ulong b,ulong *outhi,ulong *outlo){
	uint a32=a/((ulong)4294967296);
	uint a10=a%((ulong)4294967296);
	uint b32=b/((ulong)4294967296);
	uint b10=b%((ulong)4294967296);
	
	uint a3=a32/65536;
	uint a2=a32%65536;
	uint a1=a10/65536;
	uint a0=a10%65536;
	
	uint b3=b32/65536;
	uint b2=b32%65536;
	uint b1=b10/65536;
	uint b0=b10%65536;
	
	uint C1,C0,C3,C2,C4,C5;
	uint plmflg=0;//プラスマイナスフラグ
	
	
	
	mymul64(a1,a0,b1,b0,&C1,&C0);
	mymul64(a3,a2,b3,b2,&C3,&C2);
	
	//C1=mul_hi(a10,b10);C0=a10*b10;
	//C3=mul_hi(a32,b32);C2=a32*b32;
	
	
	if (a32<a10){
		a32=a10-a32;
		plmflg++;
	}else{
		a32-=a10;
	}
	
	if (b32<b10){
		b32=b10-b32;
		plmflg++;
	}else{
		b32-=b10;
	}
	
	mymul64(a32/65536,a32%65536,b32/65536,b32%65536,&C5,&C4);
	//C5=mul_hi(a32,b32);C4=a32*b32;
	
	
	
	
	uint flg=0;//下のほうで使う繰り上がりフラグ
	if (plmflg%2==0){//最後にC3から1引かないといけない
		C4=~C4;
		C5=~C5;
		C4+=1;
		flg=(C4==0);
	}
	
	
	uint tmp;
	
	tmp=C4;
	C4+=C1;
	if (C4<tmp)flg++;
	tmp=C4;
	
	C4+=C0;
	if (C4<tmp)flg++;
	tmp=C4;
	
	C4+=C2;
	if (C4<tmp)flg++;
	//tmp=C1;
	
	tmp=C5+flg;
	flg=0;
	if (tmp<C5)flg++;
	C5=tmp;
	C5+=C2;
	if (C5<tmp)flg++;
	tmp=C5;
	
	C5+=C1;
	if (C5<tmp)flg++;
	tmp=C5;
	
	C5+=C3;
	if (C5<tmp)flg++;
	//tmp=C5;
	
	C3+=flg;
	C3-=(plmflg%2==0);
	*outhi=((ulong)C3)*(ulong)4294967296+(ulong)C5;
	*outlo=((ulong)C4)*(ulong)4294967296+(ulong)C0;
}


