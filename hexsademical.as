#module hex

#deffunc twosum array a,array outd
	x = (a.0 + a.1);
	tmp= (x - a.0);
	y = (a.0 - (x - tmp)) + (a.1 - tmp);
	//ddim outd,2
	outd.0=x;
	outd.1=y;
	return

#deffunc addcab array a,array b,array outd
	ddim ddtmp,2
	ddtmp=a.0,b.0;
	ddim cz,2
	twosum ddtmp,cz
	cz.1 = cz.1 + a.1 + b.1;
	twosum cz,outd
	return 

#defcfunc hexadecimal_dd array ansd
	gx=ginfo_cx
	gy=ginfo_cy

	if (ansd.0<0.0){
		ddim ddt_,2:ddt_=1.0,0.0
		ddim ansd_,2
		addcab ansd,ddt_,ansd_
		ansd.0=ansd_.0
		ansd.1=ansd_.1
	}
	

	sdim mschar,1
	dim outdd,6//6—v‘f–Ú‚Ù‚Ç‘å‚«‚¢Œ…‚ğ‚Á‚Ä‚¢‚é‚Æ‚·‚é
	
		repeat 14
		ansd.0*=256.0
		ansd.1*=256.0
		x = ansd.0 + ansd.1
		tmp= x - ansd.0
		y = (ansd.0 - (x - tmp)) + (ansd.1 - tmp)
		ansd.0=x
		ansd.1=y

		moji=int(ansd.0)
		if (moji<256)&(ansd.0>=0.0){
			poke outdd,23-cnt,moji
			ansd.0-=moji
		}else{
			if moji==256{
				moji=moji\256
				idx=23-cnt+1
				if (idx<24){
					bidx=idx/4
					lidx=idx\4
					addv=1<<(lidx*8)
					outdd.bidx+=addv
					repeat 5-bidx
						if (outdd.bidx>=0)&(outdd.bidx<addv){
							bidx++
							addv=1
							outdd.bidx+=addv
						}else{
							break
						}
					loop
				}
				poke outdd,23-cnt,moji
				ansd.0-=256.0
			}
			
			if (ansd.0<0.0){
				moji=int(ansd.0+256.0)
				idx=23-cnt+1
				if (idx<24){
					bidx=idx/4
					lidx=idx\4
					addv=1<<(lidx*8)
					outdd.bidx-=addv
					repeat 5-bidx
						if (outdd.bidx<0)&(outdd.bidx>=-addv){
							bidx++
							addv=1
							outdd.bidx-=addv
						}else{
							break
						}
					loop
				}
				poke outdd,23-cnt,moji
				ddim ddt_,2:ddt_=256.0,0.0
				ddim ansd_,2
				addcab ansd,ddt_,ansd_
				ansd.0=ansd_.0
				ansd.1=ansd_.1
			}
		}
		loop
	retstr=hexadecimal_i32(outdd)
	return retstr

//“Y‚¦š‚ª‘å‚«‚¢‚Ù‚Ç‘å‚«‚¢”š‚Æ”F¯
#defcfunc hexadecimal_i32 array dd
	sdim outstr,48
	
	repeat 8*3
	a=peek(dd,23-cnt)
	b=a/16
	if (b<10){
		outstr+=str(b)
	}else{
		sdim s,1
		poke s,0,97-10+b
		outstr+=s
	}

	b=a\16
	if (b<10){
		outstr+=str(b)
	}else{
		sdim s,1
		poke s,0,97-10+b
		outstr+=s
	}
	loop
	return outstr
#global