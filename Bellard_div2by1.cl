#define CREATETABLEFLAG































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
































































































ulong umullo(ulong a, ulong b)
{
	return a * b;
}

void umul(ulong a, ulong b, ulong *p1, ulong *p0)
{
	*p1 = mul_hi(a,b);
	*p0 = a*b;
}

ulong umulhi(ulong a, ulong b)
{
	return mul_hi(a,b);
}


ulong CreateTable(uint idx){
	return ((1 << 19) - 3 * (1 << 8)) / (idx+256);
}

/* Algorithm 2 from Mﾃｶller and Granlund
   "Improved division by invariant integers". */
ulong reciprocal_word(ulong d)
{
        ulong d0, d9, d40, d63, v0, v1, v2, ehat, v3, v4, hi, lo;
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

        d0 = d & 1;
        d9 = d >> 55;
        d40 = (d >> 24) + 1;
        d63 = (d >> 1) + d0;
#ifdef CREATETABLEFLAG
		v0 = CreateTable(d9 - (1 << 8));
#else
		v0 = table[d9 - (1 << 8)];
#endif
        v1 = (v0 << 11) - (umullo(umullo(v0, v0), d40) >> 40) - 1;
        v2 = (v1 << 13) + (umullo(v1, (1UL << 60) - umullo(v1, d40)) >> 47);
        ehat = (v2 >> 1) * d0 - umullo(v2, d63);
        v3 = (v2 << 31) + (umulhi(v2, ehat) >> 1);
        umul(v3, d, &hi, &lo);
        v4 = v3 - (hi + d + (lo + d < lo));
        return v4;
}

/* Algorithm 4 from Mﾃｶller and Granlund
   "Improved division by invariant integers".
   Divide u1:u0 by d, returning the quotient and storing the remainder in r.
   v is the approximate reciprocal of d, as computed by reciprocal_word. */
ulong div2by1(ulong u1, ulong u0, ulong d, ulong *r, ulong v)
{
        ulong q0, q1;
        umul(v, u1, &q1, &q0);
        q0 = q0 + u0;
        q1 = q1 + u1 + (q0 < u0);
        q1++;
        *r = u0 - umullo(q1, d);
        q1 = (*r > q0) ? q1 - 1 : q1;
        *r = (*r > q0) ? *r + d : *r;
        if (*r >= d) {
                q1++;
                *r -= d;
        }
        return q1;
}
/* Count leading zeros. */
/*
int clz(ulong x)
{
        int n = 0;
        while ((x << n) <= UINT64_MAX / 2) n++;
        return n;
}
*/

/* Right-shift that also handles the 64 case. */
ulong shr(ulong x, int n)
{
        return n < 64 ? (x >> n) : 0;
}

/* Divide n-place integer u by d, yielding n-place quotient q. */
void divnby1(int n, const ulong *u, ulong d, ulong *q)
{
        ulong v, k, ui;
        int l, i;
        /* Normalize d, storing the shift amount in l. */
        l = clz(d);
        d <<= l;
        /* Compute the reciprocal. */
        v = reciprocal_word(d);
        /* Perform the division. */
        k = shr(u[n - 1], 64 - l);
        for (i = n - 1; i >= 1; i--) {
                ui = (u[i] << l) | shr(u[i - 1], 64 - l);
                q[i] = div2by1(k, ui, d, &k, v);
        }
        q[0] = div2by1(k, u[0] << l, d, &k, v);
}

/* Multiply n-place integer u by x in place, returning the overflow word. */
ulong mulnby1(int n, ulong *u, ulong x)
{
        ulong k, p1, p0;
        int i;
        k = 0;
        for (i = 0; i < n; i++) {
                umul(u[i], x, &p1, &p0);
                u[i] = p0 + k;
                k = p1 + (u[i] < p0);
        }
        return k;
}

/* Compute x * y mod n, where n << s is normalized and
   v is the approximate reciprocal of n << s. */
ulong mulmodn(ulong x, ulong y, ulong n, int s, ulong v)
{
        ulong hi, lo, r;
        umul(x, y, &hi, &lo);
        div2by1((hi << s) | shr(lo, 64 - s), lo << s, n << s, &r, v);
        return r >> s;
}

/* Compute x^p mod n by means of left-to-right binary exponentiation. */
ulong powmodn(ulong x, ulong p, ulong n)
{
        ulong res, v;
        int i, l, s;
        s = clz(n);
        v = reciprocal_word(n << s);
        res = x;
        l = 63 - clz(p);
        for (i = l - 1; i >= 0; i--) {
                res = mulmodn(res, res, n, s, v);
                if (p & (1UL << i)) {
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
		nmr=powmodn(1024,d-k,dnm);
		//k^-1のところ。答えを適宜反転
		if ((numesign+k%2)%2==1){
			nmr=dnm-nmr;
		}
		
		ulong u[4]={0,0,0,nmr};
		ulong q[4];
		divnby1(4,u,dnm,q);
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




