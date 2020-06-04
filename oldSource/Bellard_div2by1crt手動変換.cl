#define CREATETABLEFLAG


//(a1a0)*(b1b0)
//32bit*32bit=64bit
uint2 mymul64(uint2 a10,uint2 b10){
	uint2 outhilo;
	//案1
	uint ab00=a10.x*b10.x;
	uint ab11=a10.y*b10.y;
	uint ab01=a10.x*b10.y;
	uint ab10=a10.y*b10.x;
	
	uint tmp=ab01+ab10;
	if (tmp<ab01)ab11+=65536;
	
	outhilo.x=ab00+(tmp%65536)*65536;
	if (outhilo.x<ab00){
		ab11++;
	}
	
	outhilo.y=ab11+tmp/65536;
	return outhilo;
}

uint4 mymul128(uint2 a,uint2 b){
	uint a32=a.y;
	uint a10=a.x;
	uint b32=b.y;
	uint b10=b.x;
	
	uint2 u2a10,u2a32;
	u2a32.y=a32/65536;
	u2a32.x=a32%65536;
	u2a10.y=a10/65536;
	u2a10.x=a10%65536;
	
	uint2 u2b10,u2b32;
	u2b32.y=b32/65536;
	u2b32.x=b32%65536;
	u2b10.y=b10/65536;
	u2b10.x=b10%65536;
	
	uint C1,C0,C3,C2,C4,C5;
	uint plmflg=0;//プラスマイナスフラグ
	
	uint2 u2out;
	u2out=mymul64(u2a10,u2b10);
	C1=u2out.y;
	C0=u2out.x;
	u2out=mymul64(u2a32,u2b32);
	C3=u2out.y;
	C2=u2out.x;
	
	
	
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
	
	
	uint2 u2ina;u2ina.y=a32/65536;u2ina.x=a32%65536;
	uint2 u2inb;u2inb.y=b32/65536;u2inb.x=b32%65536;
	u2out=mymul64(u2ina,u2inb);
	C5=u2out.y;
	C4=u2out.x;
	
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
	
	uint4 out4;
	out4.x=C0;
	out4.y=C4;
	out4.z=C5;
	out4.w=C3;
	return out4;
}


uint2 mymulhi128(uint2 a,uint2 b){
	uint a32=a.y;
	uint a10=a.x;
	uint b32=b.y;
	uint b10=b.x;
	
	uint2 u2a10,u2a32;
	u2a32.y=a32/65536;
	u2a32.x=a32%65536;
	u2a10.y=a10/65536;
	u2a10.x=a10%65536;
	
	uint2 u2b10,u2b32;
	u2b32.y=b32/65536;
	u2b32.x=b32%65536;
	u2b10.y=b10/65536;
	u2b10.x=b10%65536;
	
	uint C1,C0,C3,C2,C4,C5;
	uint plmflg=0;//プラスマイナスフラグ
	
	uint2 u2out;
	u2out=mymul64(u2a10,u2b10);
	C1=u2out.y;
	C0=u2out.x;
	u2out=mymul64(u2a32,u2b32);
	C3=u2out.y;
	C2=u2out.x;
	
	
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
	
	uint2 u2ina;u2ina.y=a32/65536;u2ina.x=a32%65536;
	uint2 u2inb;u2inb.y=b32/65536;u2inb.x=b32%65536;
	u2out=mymul64(u2ina,u2inb);
	C5=u2out.y;
	C4=u2out.x;
	
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
	//return ((ulong)C3)*(ulong)4294967296+(ulong)C5;
	uint2 out2;
	out2.x=C5;
	out2.y=C3;
	return out2;
}



uint2 mymullo128(uint2 a,uint2 b){
	uint a32=a.y;
	uint a10=a.x;
	uint b32=b.y;
	uint b10=b.x;
	
	uint a1=a10/65536;
	uint a0=a10%65536;
	
	uint b1=b10/65536;
	uint b0=b10%65536;
	
	uint C1,C0;
	
	uint2 u2ina;u2ina.x=a0;u2ina.y=a1;
	uint2 u2inb;u2inb.x=b0;u2inb.y=b1;
	uint2 u2out=mymul64(u2ina,u2inb);
	C1=u2out.y;
	C0=u2out.x;
	//mymul64(a1,a0,b1,b0,&C1,&C0);
	C1+=a32*b10+a10*b32;
	
	//return ((ulong)C1)*(ulong)4294967296+(ulong)C0;
	
	uint2 out2;
	out2.x=C0;
	out2.y=C1;
	return out2;
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






























































































int clz2(uint2 x2)
{
	uint x;
	if (x2.y!=0){
		x=x2.y;
	}else{
		x=x2.x;
	}
		
	int n=16,nn=8;
	for(;nn>0;nn/=2)
	{
		if ((1<<n)<=x){
			n+=nn;
		}else{
			n-=nn;
		}
	}
	
	
	if ((1<<n)<=x){
		n++;
	}
	
	
	if (x2.y!=0){
		n+=32;
	}
	return 64-n;
}

/* Right-shift that also handles the 64 case. */
uint2 shr(uint2 x, int n)
{
	uint2 outd;
	if (n>=32){
		outd.y=0;
		outd.x=x.y>>(n-32);
	}else{
		outd.y=x.y>>n;
		outd.x=(x.y%(1<<n))<<(32-n);
		outd.x+=x.x>>n;
	}
	return outd;
}
uint2 shl(uint2 x, int n)
{
	uint2 outd;
	if (n>=32){
		outd.x=0;
		outd.y=x.x<<(n-32);
	}else{
		outd.x=x.x<<n;
		outd.y=x.x>>(32-n);
		outd.y+=x.y<<n;
	}
	return outd;
}


uint CreateTable(uint idx){
	return (524288 - 3 * 256) / (idx+256);
}


//単純な足し算、オーバーフロー考慮なし
uint2 uladd(uint2 a,uint2 b){
	a.x+=b.x;
	if (a.x<b.x)a.y++;
	a.y+=b.y;
	return a;
}

//足し算、オーバーフロー考慮あり
uint3 uladdofw(uint2 a,uint2 b){
	uint3 outd;
	outd.z=0;
	outd.x=a.x+b.x;
	if (outd.x<b.x){
		a.y++;
		if (a.y==0)outd.z=1;
	}
	a.y+=b.y;
	outd.y=a.y;
	if (a.y<b.y)outd.z=1;
	return outd;
}



/* Algorithm 2 from Mﾃｶller and Granlund
   "Improved division by invariant integers". */
uint2 reciprocal_word(uint2 d)
{
		//uint2 d;d.y=uld/4294967296UL;d.x=uld%4294967296UL;
        uint2 d0, d9, d40, d63, v0, v1, v2, ehat, v3, v4, hi, lo;
		ehat.x=0;ehat.y=0;
        const uint table[] = {
        /* Generated with:
           for (int i = (1 << 8); i < (1 << 9); i++)
                   printf("0x%03x,\n", ((1 << 19) - 3 * (1 << 8)) / i); */
        0x7fd, 0x7f5, 0x7ed, 0x7e5, 0x7dd, 0x7d5, 0x7ce, 0x7c6, 0x7bf, 0x7b7,
        0x7b0, 0x7a8, 0x7a1, 0x79a, 0x792, 0x78b, 0x784, 0x77d, 0x776, 0x76f,
        0x768, 0x761, 0x75b, 0x754, 0x74d, 0x747, 0x740, 0x739, 0x733, 0x72c,
        0x726, 0x720, 0x719, 0x713, 0x70d, 0x707, 0x700, 0x6fa, 0x6f4, 0x6ee,
        0x6e8, 0x6e2, 0x6dc, 0x6d6, 0x6d1, 0x6cb, 0x6c5, 0x6bf, 0x6ba, 0x6b4,
        0x6ae, 0x6a9, 0x6a3, 0x69e, 0x698, 0x693, 0x68d, 0x688, 0x683, 0x67d,
        0x678, 0x673, 0x66e, 0x669, 0x664, 0x65e, 0x659, 0x654, 0x64f, 0x64a,
        0x645, 0x640, 0x63c, 0x637, 0x632, 0x62d, 0x628, 0x624, 0x61f, 0x61a,
        0x616, 0x611, 0x60c, 0x608, 0x603, 0x5ff, 0x5fa, 0x5f6, 0x5f1, 0x5ed,
        0x5e9, 0x5e4, 0x5e0, 0x5dc, 0x5d7, 0x5d3, 0x5cf, 0x5cb, 0x5c6, 0x5c2,
        0x5be, 0x5ba, 0x5b6, 0x5b2, 0x5ae, 0x5aa, 0x5a6, 0x5a2, 0x59e, 0x59a,
        0x596, 0x592, 0x58e, 0x58a, 0x586, 0x583, 0x57f, 0x57b, 0x577, 0x574,
        0x570, 0x56c, 0x568, 0x565, 0x561, 0x55e, 0x55a, 0x556, 0x553, 0x54f,
        0x54c, 0x548, 0x545, 0x541, 0x53e, 0x53a, 0x537, 0x534, 0x530, 0x52d,
        0x52a, 0x526, 0x523, 0x520, 0x51c, 0x519, 0x516, 0x513, 0x50f, 0x50c,
        0x509, 0x506, 0x503, 0x500, 0x4fc, 0x4f9, 0x4f6, 0x4f3, 0x4f0, 0x4ed,
        0x4ea, 0x4e7, 0x4e4, 0x4e1, 0x4de, 0x4db, 0x4d8, 0x4d5, 0x4d2, 0x4cf,
        0x4cc, 0x4ca, 0x4c7, 0x4c4, 0x4c1, 0x4be, 0x4bb, 0x4b9, 0x4b6, 0x4b3,
        0x4b0, 0x4ad, 0x4ab, 0x4a8, 0x4a5, 0x4a3, 0x4a0, 0x49d, 0x49b, 0x498,
        0x495, 0x493, 0x490, 0x48d, 0x48b, 0x488, 0x486, 0x483, 0x481, 0x47e,
        0x47c, 0x479, 0x477, 0x474, 0x472, 0x46f, 0x46d, 0x46a, 0x468, 0x465,
        0x463, 0x461, 0x45e, 0x45c, 0x459, 0x457, 0x455, 0x452, 0x450, 0x44e,
        0x44b, 0x449, 0x447, 0x444, 0x442, 0x440, 0x43e, 0x43b, 0x439, 0x437,
        0x435, 0x432, 0x430, 0x42e, 0x42c, 0x42a, 0x428, 0x425, 0x423, 0x421,
        0x41f, 0x41d, 0x41b, 0x419, 0x417, 0x414, 0x412, 0x410, 0x40e, 0x40c,
        0x40a, 0x408, 0x406, 0x404, 0x402, 0x400
        };
		d0.y=0;
        d0.x = d.x & 1;
        d9 = shr(d,55);
        d40 = uladd(shr(d,24) , (uint2){1,0});
        d63 = uladd(shr(d,1) , d0);
#ifdef CREATETABLEFLAG
		v0.y=0;
		v0.x = CreateTable(d9.x - 256);
#else
		v0.y=0;
		v0.x = table[d9.x - 256];
#endif
        v1 = uladd(uladd(shl(v0,11) ,-shr( mymullo128(mymullo128(v0, v0), d40) , 40 )) ,(uint2){-1,0});
        v2 = uladd(shl(v1,13) ,shr(mymullo128(v1, uladd((uint2){0,1<<28} ,-mymullo128(v1, d40)) ) , 47));
		if (d0.x==1)ehat=shr(v2,1);
        ehat = uladd(ehat,-mymullo128(v2, d63));
        v3 = uladd(shl(v2,31) , shr(mymulhi128(v2, ehat),1));
        uint4 out4=mymul128(v3, d);
		lo.x=out4.x;
		lo.y=out4.y;
		hi.x=out4.z;
		hi.y=out4.w;
		
		uint3 outtmp=uladdofw(lo,d);
        v4 = uladd(v3,-uladd(uladd(hi,d),(uint2){outtmp.z,0}));
		//ulong outv4=(ulong)v4.x+(ulong)v4.y*(1UL<<32UL);
        return v4;
}

/* Algorithm 4 from Mﾃｶller and Granlund
   "Improved division by invariant integers".
   Divide u1:u0 by d, returning the quotient and storing the remainder in r.
   v is the approximate reciprocal of d, as computed by reciprocal_word. */
uint2 div2by1(uint2 u1, uint2 u0, uint2 d, uint2 *r, uint2 v)
{
        uint2 q0, q1;
		uint4 out4=mymul128(v, u1);
		q0.x=out4.x;
		q0.y=out4.y;
		q1.x=out4.z;
		q1.y=out4.w;
		
		uint3 out3=uladdofw(q0,u0);
		q0.x=out3.x;
		q0.y=out3.y;
        q1 = uladd(q1,u1);
        q1+=out3.z+1;
		
        *r = uladd(u0,-mymullo128(q1, d));
		
		bool flag=0;
		if ((*r).y>q0.y){
			flag=1;
		}else{
			if ((*r).y==q0.y){
				if ((*r).x>q0.x)flag=1;
			}
		}
		
		if (flag){
			q1=uladd(q1,(uint2){-1,0});
			*r=uladd(*r,d);
		}
        //q1 = (*r > q0) ? q1 - 1 : q1;
        //*r = (*r > q0) ? *r + d : *r;
		
		flag=0;
		if ((*r).y >= d.y) {
			flag=1;
		}else{
			if ((*r).y == d.y){
				if ((*r).x >= d.x)flag=1;
			}
		}
		if (flag){
			
			q1=uladd(q1,(uint2){1,0});
			*r = uladd(*r,-d);
		}
        //if (*r >= d) {
        //        q1++;
        //        *r -= d;
        //}
        return q1;
}

/* Divide n-place integer u by d, yielding n-place quotient q. */
void divnby1(int n, const uint2 *u, uint2 d, uint2 *q)
{
        uint2 v, k, ui;
        int l, i;
        /* Normalize d, storing the shift amount in l. */
        l = clz2(d);
		d=shl(d,l);
        /* Compute the reciprocal. */
        v = reciprocal_word(d);
        /* Perform the division. */
        k = shr(u[n - 1], 64 - l);
        for (i = n - 1; i >= 1; i--) {
                ui = shl(u[i],l) | shr(u[i - 1], 64 - l);
                q[i] = div2by1(k, ui, d, &k, v);
        }
		q[0] = div2by1(k, shl(u[0],l), d, &k, v);
        //q[0] = div2by1(k, shl(u[0],l), d, &k, v);
}

/* Multiply n-place integer u by x in place, returning the overflow word. */
uint2 mulnby1(int n, uint2 *u, uint2 x)
{
        uint2 k, p1, p0;
        int i;
        k.x = 0;k.y = 0;
        for (i = 0; i < n; i++) {
				uint4 out4=mymul128(u[i], x);
				p1.x=out4.z;
				p1.y=out4.w;
				p0.x=out4.x;
				p0.y=out4.y;
				uint3 out3=uladdofw(p0,k);
				u[i].x=out3.x;
				u[i].y=out3.y;
                //u[i] = uladd(p0 + k);
                k = uladd(p1,(uint2){out3.z,0});
        }
        return k;
}

/* Compute x * y mod n, where n << s is normalized and
   v is the approximate reciprocal of n << s. */
uint2 mulmodn(uint2 x, uint2 y, uint2 n, int s, uint2 v)
{
        uint2 hi, lo, r;
		uint4 out4=mymul128(x, y);
		lo.x=out4.x;
		lo.y=out4.y;
		hi.x=out4.z;
		hi.y=out4.w;
		
        div2by1(shl(hi,s) | shr(lo, 64 - s), shl(lo,s), shl(n,s), &r, v);
        return shr(r,s);
}

/* Compute x^p mod n by means of left-to-right binary exponentiation. */
uint2 powmodn(uint2 x, uint2 p, uint2 n)
{
        uint2 res, v;
        int i, l, s;
        s = clz2(n);
		
        v = reciprocal_word(shl(n,s));
        res = x;
        l = 63 - clz2(p);
        for (i = l - 1; i >= 0; i--) {
                res = mulmodn(res, res, n, s, v);
				uint2 tmp=shr(p,i);
				if (tmp.x%2==1) {
                //if (p & (1UL << i)) {
                        res = mulmodn(res, x, n, s, v);
                }
        }
        return res;
}















//メイン計算部分モンゴメリ乗算版64bit、2つのdouble-double(105bit*2)を64bit整数*3にまとめる
//というバージョンをさらに改造してリフレッシュしたやつ
//モンゴメリ乗算、最後の割り算はdiv2by1のソースをネットのからコピペしてやっている
__kernel void Sglobal64mtg_192_Refresh(__global ulong *bigSum,const ulong offset,const ulong d,const ulong k_max,const long numesign,const ulong den0,const ulong den1) {
	ulong gsize=get_global_size(0);
	ulong idx = get_global_id(0);
	ulong k=idx+offset;
	ulong dnm=den0*k+den1;//分母
	ulong dnmadd=gsize*den0;
	ulong nmr;//分子
	
	//double-double精度を2つ使って192bitに結果を収める。上のループと比べると試行回数は１回なので少し非効率でも大丈夫
	ulong ulsum0=0;//最上位桁
	ulong ulsum1=0;//中間
	ulong ulsum2=0;//最下位桁
	
	
	for(;k<k_max;k+=gsize)
	{
		ulong dk=d-k;
		uint2 u2nmr=powmodn((uint2){1024,0},(uint2){dk%4294967296UL,dk/4294967296UL},(uint2){dnm%4294967296UL,dnm/4294967296UL});
		nmr=(ulong)u2nmr.x+(ulong)u2nmr.y*(1UL<<32UL);
		
		//k^-1のところ。答えを適宜反転
		if ((numesign+k%2)%2==1){
			nmr=dnm-nmr;
		}
		
		uint2 u[4];//={0,0,0,nmr};
		u[0].x=0;u[0].y=0;
		u[1].x=0;u[1].y=0;
		u[2].x=0;u[2].y=0;
		u[3].x=nmr%4294967296UL;u[3].y=nmr/4294967296UL;
		
		uint2 q2[4];
		
		divnby1(4,u,(uint2){dnm%4294967296UL,dnm/4294967296UL},q2);
		
		ulong q[4];
		for(int iiii=0;iiii<4;iiii++){
			q[iiii]=(ulong)q2[iiii].x+(ulong)q2[iiii].y*(1UL<<32UL);
		}
		
		
		
		ulsum2+=q[0];
		q[1]+=(ulsum2<q[0]);
		q[2]+=(q[1]==0);
		ulsum1+=q[1];
		q[2]+=(ulsum1<q[1]);
		ulsum0+=q[2];

		dnm+=dnmadd;
	}
	//長いループ終了
	
	
	__local ulong p[128*3];
	shared_reduction_ulong3(&ulsum0,&ulsum1,&ulsum2,p);
	
	//グローバルメモリに加算書き込み
	ulong3GlobalADD(ulsum0,ulsum1,ulsum2,bigSum);
}


/////////////////////////64bitバージョン　ルーチンここまで//////////////////////




