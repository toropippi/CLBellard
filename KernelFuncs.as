#module krnfncs

#deffunc numer_denom_init
	//���qnumer,����denom
	dim_i64 numer,7
	dim_i64 numer_sign,7
	dim_i64 denom0,7
	dim_i64 denom1,7
	numer		=int64(32),int64(1),int64(256),int64(64),int64(4) ,int64(4) ,int64(1)
	numer_sign	=int64(1) ,int64(1),int64(0)  ,int64(1) ,int64(1) ,int64(1) ,int64(0)//1�̓}�C�i�X�A0�̓v���X���Ӗ�����
	denom0		=int64(4) ,int64(4),int64(10) ,int64(10),int64(10),int64(10),int64(10)
	denom1		=int64(1) ,int64(3),int64(1)  ,int64(3) ,int64(5) ,int64(7) ,int64(9)
	return

#deffunc Set0memUlong3 var bigSumMem
	HCLSetKrns krnFill8@,bigSumMem,int64(0),0
	HCLDoKrn1 krnFill8@,BIGSUM_SIZE*3,64
	return

#deffunc Set0memdd var bigSumMem
	HCLSetKrns krnFill8@,bigSumMem,0.0,0
	HCLDoKrn1 krnFill8@,BIGSUM_SIZE*2,64
	return

#deffunc BatchCalc var k_start,var k_end,int formulano,var bigSumMem,var smallSumMem
	//k_max:dispatch�����J�[�l������k_max-1�܂Ń��[�v�v�Z�����
	k_max=k_start
	offset=k_max

	//���ꂪ32bit�Ɏ��܂��
	loopmax32=((int64(1)<<32)-denom1.formulano-1)/denom0.formulano+1
	loopmax32=Min64(loopmax32,d@)
	loopmax32=Min64(loopmax32,k_end)
		repeat -1
		if offset>=loopmax32:break
		k_max=Min64(k_max+GLOBAL_WORK_SIZE*(16-8*DEBUG_99LOAD@),loopmax32)
		HCLSetKrns krnSglobal32@,bigSumMem,offset,d@,k_max,numer_sign.formulano,denom0.formulano,denom1.formulano
		HCLDoKrn1 krnSglobal32@,GLOBAL_WORK_SIZE,LOCAL_WORK_SIZE
		if DEBUG_99LOAD@==1:HCLFinish:await 1
		offset=k_max
		loop
	

	//���ꂪ32bit�Ɏ��܂�Ȃ���
	loopmax64=Min64(k_end,d@)
	repeat -1
		if offset>=loopmax64:break
		k_max=Min64(k_max+GLOBAL_WORK_SIZE*(32-24*DEBUG_99LOAD@),loopmax64)
		HCLSetKrns krnSglobal64@,bigSumMem,offset,d@,k_max,numer_sign.formulano,denom0.formulano,denom1.formulano
		HCLDoKrn1 krnSglobal64@,GLOBAL_WORK_SIZE,LOCAL_WORK_SIZE
		if DEBUG_99LOAD@==1:HCLFinish:await 1
		offset=k_max
	loop

	//���C���v�Z��k���[�v�̌�̐����[�v���v�Z
	if (offset==d@){
		HCLSetKrns krnSglobalafter@,bigSumMem,d@,numer_sign.formulano,denom0.formulano,denom1.formulano
		HCLDoKrn1 krnSglobalafter@,1,1//�]���Ƀ��[�v�܂킵�āA���̕���bigSumMem[0]�ɉ��Z����
	}

	//���v�v�Z
	HCLSetKrns krnSsum@,bigSumMem,smallSumMem
	HCLDoKrn1 krnSsum@,BIGSUM_SIZE,LOCAL_WORK_SIZE//65536��256���v
	HCLSetKrns krnSsum@,smallSumMem,bigSumMem
	HCLDoKrn1 krnSsum@,BIGSUM_SIZE/256,LOCAL_WORK_SIZE,0//256��1���v�A����ɂ��̃J�[�l���̃C�x���g���擾���ďI�������m������
	return

#deffunc AddAns int formulano,var bigSumMem,var dev_ans
	//presicion��dd�Ȃ�bigSumMem[0],bigSumMem[1]�ɓ�����
	//presicion��ulong3�Ȃ�bigSumMem[0],bigSumMem[1],bigSumMem[1]�ɓ����������Ă���
	//�����gpu��̃�����dev_ans�ɂ܂Ƃ߂Ă���
	HCLSetKrns krnSum7@,dev_ans,bigSumMem,numer.formulano
	HCLDoKrn1 krnSum7@,1,1
	return
#global
numer_denom_init