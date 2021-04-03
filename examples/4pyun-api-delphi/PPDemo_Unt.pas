unit PPDemo_Unt;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,  PPSDK ,  superobject ,
  Dialogs, StdCtrls;

type
  TPPDemo_Frm = class(TForm)
    Button1: TButton;
    Memo1: TMemo;
    Button2: TButton;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
    procedure  PP_SumPayJE (CarNo, passport,gate_id :String ;seqno:Integer)  ;
    procedure  PP_PayFinish(Pmag  :String  )  ;
  public
    { Public declarations }
  end;
  procedure  PYunAPIEventCallback   (event_type:Integer; Pmsg:PChar); stdcall;
  Function   PYunAPIRequestCallback (seqno:Integer; payload :PChar):Integer; stdcall;
var
  PPDemo_Frm: TPPDemo_Frm;

     //cdecl

implementation

{$R *.dfm}

//�¼�����
procedure  PYunAPIEventCallback(event_type:Integer; Pmsg:PChar); stdcall;
begin
  case event_type of
      1: PPDemo_Frm.Memo1.Lines.Add('---API��Ȩ�ɹ�');
     -1: PPDemo_Frm.Memo1.Lines.Add('---API��Ȩʧ��');
     -2: PPDemo_Frm.Memo1.Lines.Add('---TCP�����쳣');
     -3: PPDemo_Frm.Memo1.Lines.Add('---TCP���ӹر�');
  end;
end;


// ����ɨ��֧��(���ơ�����)�� ����Ԥ֧�������Ƴ��볡
//��������ص�
Function  PYunAPIRequestCallback (seqno:Integer; payload :PChar):Integer; stdcall;
var
  jorec   :ISuperObject;
  service ,Pmsg :String;
  CarNo  ,passport  ,gate_id  :String;
begin
  Pmsg    :=String(payload) ;
  jorec   :=so(Pmsg);
  service :=jorec['service'].AsString;
  if service='service.parking.payment.billing' then //��ѯ�շѽ��
  begin
     PPDemo_Frm.Memo1.Lines.Add('PP���Ͳ�ѯ���������='+IntToStr(seqno)+' ����='+Pmsg);
     CarNo     :=jorec['plate'].AsString;      //���ڸ����ƺ���
     passport  :=jorec['passport'].AsString;   //�û�ͨ��֤ID, ���Ƴ�����
     gate_id   :=jorec['gate_id'].AsString;    //���ơ����Ƴ�����ֱ��
     {
     1������Ԥ֧��  ��plateΪ���ƺ���   ,passport��gate_idΪ��
     2�����Ƴ���ֱ����plateΪ���ƺ���   ,passportΪ�գ�gate_idΪ����ͨ��   , ����Ҫ���Ǹ����ĳ��Ʒ�����
     3�����Ƴ���ֱ����passportͨ��֤ID  ,plateΪ��   ��gate_idΪ����ͨ��
     }
     PPDemo_Frm.PP_SumPayJE(CarNo,passport,gate_id ,seqno);
  end;
  if service='service.parking.payment.result' then //����֧�����֪ͨ�շ�ϵͳ
  begin
     PPDemo_Frm.Memo1.Lines.Add('PP����֧���ɹ�: ���='+IntToStr(seqno)+' ����='+Pmsg);
     PPDemo_Frm.PP_PayFinish(Pmsg);
  end;

  
end;



//����֧�����֪ͨ�շ�ϵͳ
procedure  TPPDemo_Frm.PP_PayFinish(Pmag  :String  )  ;
begin
  {
  gate_id":""  ,                              //ͨ�����ID, ����ʱ�ɴ��ݴ�����բ;
  parking_order":"TC20180731155256",          //ͣ��֧��������, ԭ�ͻ����ύ.
  parking_serial":"20180731155256",           //ͣ����ˮ, ԭ�ͻ����ύ.
  pay_origin":"0",                            //0-PPͣ��  4-֧���� 8-΢��
  pay_origin_desc":"PYun",                    //֧����Դ˵��, ����:PPͣ��
  pay_serial":"20180731155233075500218569",   //PPͣ��֧����ˮ, ���˿���.
  pay_time":"20180731155246",                 //֧��ʱ��, ��ʽ: yyyyMMddHHmmss .
  value":"1",                                 //֧�����(��λ��) .
  }

end;



//��ѯ�շѽ��
procedure  TPPDemo_Frm.PP_SumPayJE(CarNo , passport,gate_id:String ;seqno:Integer)  ;
var
  service,version ,charset ,result_code ,pmessage ,sign , plate ,parking_serial ,parking_order  ,enter_time ,card_id :String;
  parking_time ,total_value , free_value ,  paid_value  ,locking_status  ,pay_value  : Integer;
  jo    :ISuperObject;
  jostr :String;
  Ret   :Integer;
begin
{1001 ������ȡ�ɹ�, ҵ�����������.
1002 δ��ѯ��ͣ����Ϣ.
1003 �¿�����, ������֧��.
1401 ǩ������, ��������.
1500 �ӿڴ����쳣.
}
  
  service        :='service.parking.payment.billing' ;//������: service.parking.payment.billing
  version        :='1.0';                             //�汾��: 1.0
  charset        :='UTF-8';                           //�ַ���: UTF�\8
  result_code    :='1001';                            //״̬��:
  pmessage       :='������ȡ�ɹ�, ҵ�����������';    //״̬�봦������, ��:���ش�����Ϣ
  sign           :='';                                //ǩ��
  plate          :=CarNo;                             //ʶ���ƺ���
  card_id        :='';                                //���Ƴ���ȡ�������ر��ص����⿨ID/���⳵��.
  parking_serial :=FormatDatetime('yyyymmddhhnnss',now);      //ͣ����ˮ, ��ʶ����ĳ��ͣ���¼�, �豣֤��ͣ������Ψһ.
  parking_order  :='TC'+FormatDatetime('yyyymmddhhnnss',now);     //ͣ��֧��������, �豣֤��ͣ������Ψһ.ע:ͬһͣ�����ڲ����ظ���
  enter_time     :=FormatDatetime('yyyymmddhhnnss',now);          //�볡ʱ��, ��ʽyyyyMMddHHmmss
  parking_time   :=3600;                           //ͣ��ʱ��(��λ��)
  total_value    :=1;                             //��ͣ������(��λ��), Ϊ�û����볡�����ڻ�ȡ����ʱ���ܷ���.
  free_value     :=0;                             //���Żݽ��(��λ��), Ϊͣ�����ڵ�ǰͣ������ʱ�Ѿ�������Żݽ��, ��������Ż�ʱ�����ֵΪ��free_value��д��ʱ��ȼ۵��Żݽ��+������Ч�Żݽ��.
  paid_value     :=0;                             //��֧�����(��λ��), Ϊ����ͣ���û��Ѿ�֧���Ľ��, ���統�û���֧����һ�ʺ�, ��ʱδ�������²�ѯ����ʱ�뷵����֧�����.
  pay_value      :=1;                             //Ӧ֧�����(��λ��), ����ͣ����ϵͳ�账��������Ϊ���������ֱ�ӷ�������֧��.
  locking_status :=0;                             //������ʶ: 1����, 0δ��, 1��֧��
 
  jo:=SO();
  jo.S['service']          :=service;
  jo.S['version']          :='1.0';
  jo.S['charset']          :='UTF-8';
  jo.S['result_code']      :=result_code;
  jo.S['message']          :=pmessage;
  jo.S['sign']             :=sign;
  jo.S['plate']            :=CarNo;
  jo.S['card_id']          :=card_id;
  jo.S['parking_serial']   :=parking_serial;
  jo.S['parking_order']    :=parking_order;
  jo.S['enter_time']       :=enter_time;
  jo.I['parking_time']     :=parking_time;
  jo.I['total_value']      :=total_value;
  jo.I['free_value']       :=free_value;
  jo.I['paid_value']       :=paid_value;
  jo.I['pay_value']        :=pay_value;
  jo.I['locking_status']   :=locking_status;
  jostr   :=jo.AsString;

  Ret :=PYunAPIReply(seqno ,Pchar(jostr) );
  if Ret=0 then
     PPDemo_Frm.Memo1.Lines.Add('�շѷ��ض����ɹ�:���='+IntToStr(seqno)+' ����='+jostr)
  else
     PPDemo_Frm.Memo1.Lines.Add('�շѷ��ض���ʧ��:���='+IntToStr(seqno)+' ����='+jostr);

end;


procedure TPPDemo_Frm.Button1Click(Sender: TObject);
var
  phost ,ptype ,uuid  ,psign_mac :Pchar;
  port : Integer;
  iRet : Integer;
  A : Integer ;
  ExeFile :String;

begin
   
  ExeFile := ExtractFilepath(application.exename);


  // 1.1 �����¼����ػص�����
  PYunAPIHookEvent(@PYunAPIEventCallback);
  // 1.2 ��������ص�
  PYunAPIHookRequest(@PYunAPIRequestCallback);

	// 1.3 ���ÿ�ѡ��
	// [����]���õ�ǰ��Ŀ���̱���, �ײ�Ĭ��UTF-8����
 	iRet :=PYunAPISetOpt(PYUNAPI_OPT_CHARSET,   PCHAR('GBK')  );
  if iRet=0 then
     Memo1.Lines.Add('---������������=GBK�ɹ�')
  else
     Memo1.Lines.Add('---������������=GBKʶ��ʧ��');

   // [��ѡ]�������ģʽ, Ĭ���ڵ�ǰִ��Ŀ¼������־�ļ�  ������ģʽ: 1��, 0��
  A:=1;
  iRet :=PYunAPISetOpt(PYUNAPI_OPT_DEV_MODE,   @A);
  if iRet=0 then
     Memo1.Lines.Add('---�������ģʽ���óɹ�')
  else
     Memo1.Lines.Add('---�������ģʽ����ʧ��');

  {
	// [��ѡ]�����������ʱ��, ms
	PYunAPISetOpt(PYUNAPI_OPT_IDLE_TIME,  (void *)&idle_time);
	// [��ѡ]������Ȩ��ʱʱ��, ms
	PYunAPISetOpt(PYUNAPI_OPT_AUTH_TIME,  (void *)&auth_time);}

	// [��ѡ]������־�ļ�
	iRet :=PYunAPISetOpt(PYUNAPI_OPT_LOGGER,     PCHAR(ExeFile+'MY.log')  );
  if iRet=0 then
     Memo1.Lines.Add('---������־�ļ��ɹ�='+ExeFile+'MY.log' )
  else
     Memo1.Lines.Add('---������־�ļ�ʧ��');

  // 2. ����API, �ײ�Ὺ���̺߳��ƶ˱���TCP������
  phost    :='sandbox.gate.4pyun.com';                 //��ƽ̨����
  port     :=8661;                                      //��ƽ̨�˿�
  ptype    :='public:parking:agent';                    //�ͻ�������
  uuid     :='2adf6966-1c06-4e09-91ea-354ffc7df916';    //�ͻ���UUID, һ��UUIDֻ������һ��ʵ��
  psign_mac:='XGbVfP1oC21UHkwn';                        //�ӿ�ͨ��JSONǩ��������Կ
  iRet :=PYunAPIStart( phost ,port ,ptype,uuid,psign_mac );
  if iRet=0 then
     Memo1.Lines.Add('---����API�ɹ�')
  else
     Memo1.Lines.Add('---����APIʧ��')
end;

procedure TPPDemo_Frm.Button2Click(Sender: TObject);
begin
  PYunAPIDestroy;
end;

procedure TPPDemo_Frm.FormShow(Sender: TObject);
begin
  Button1Click(self);
end;

end.




