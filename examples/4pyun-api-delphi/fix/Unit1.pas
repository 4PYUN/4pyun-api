unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls;




CONST

  WM_PP_OrderNo    = WM_USER+109;  //PP��ѯ����


//PP��ѯ����
type
  TPP_OrderNo = Packed  Record
      CarNo     : String;    //���ƺ���
      passport  : String;    //�û�ͨ��֤ID, ���Ƴ�����
      gate_id   : String;    //���ơ����Ƴ�����ֱ����բͨ��
      seqno     : Integer;   //ָ�����
end;
pPP_OrderNo = ^TPP_OrderNo;  //����ṹ��ָ��.



type
  TForm1 = class(TForm)
  private
    { Private declarations }

    procedure  MyMsg_PP_OrderNo (var  msg:TMSG);message  WM_PP_OrderNo;  //PP��ѯ����


  public
    { Public declarations }
  end;


  procedure  ReceiveDataCallBackProc(strJsonData:PChar); stdcall;
  procedure  PYunAPIEventCallback   (event_type:Integer; Pmsg:PChar); stdcall;
  Function   PYunAPIRequestCallback (seqno:Integer; payload :PChar):Integer; stdcall;


var
  Form1: TForm1;

implementation

{$R *.dfm}


//���账��
procedure  PfSerialDataCallBack (lSerialHandle: Longint;
                                pRecvDataBuffer: PChar;
                                dwBufSize: Longword;
                                dwUser: Longint );stdcall;
begin

end;


//pp�¼����� ��������¼
procedure  PYunAPIEventCallback(event_type:Integer; Pmsg:PChar); stdcall;
begin

end;


// pp����ɨ��֧��(���ơ�����)�� ����Ԥ֧�������Ƴ��볡
//��������ص�
Function  PYunAPIRequestCallback (seqno:Integer; payload :PChar):Integer; stdcall;
var
  jorec   :ISuperObject;
  service ,Pmsg   :String;

  pPPOrderNo:pPP_OrderNo ;
begin
  Pmsg    :=String(payload) ;
  jorec   :=so(Pmsg);
  try
      service :=jorec['service'].AsString;  //��������

      if service='service.parking.payment.billing' then //��ѯ�շѽ��
      begin
         plate    :='';
         passport :='';
         gate_id  :='';
         new(pPPOrderNo);
         pPPOrderNo.CarNo       :=plate;       //���ƺ���
         pPPOrderNo.passport    :=passport;
         pPPOrderNo.gate_id     :=gate_id;
         pPPOrderNo.seqno       :=seqno;
         //���׸�ϵͳ���� ���ǳ���Ҫ!!!!
         postmessage(Form1.handle,WM_PP_OrderNo, 0, LPARAM( pPPOrderNo) );
      end;
  except
      Exit;
  end;
end;



procedure  TForm1.MyMsg_PP_OrderNo (var  msg:TMSG);   //PP��ѯ����
var
   pPPOrderNo:pPP_OrderNo ;
begin
   pPPOrderNo := pPP_OrderNo(Msg.wParam);
   try
      CarNo     :=pPPOrderNo^.CarNo ;      //���ƺ���
      passport  :=pPPOrderNo^.passport;    //�û�ͨ��֤ID, ���Ƴ�����
      gate_id   :=pPPOrderNo^.gate_id;    //���ơ����Ƴ�����ֱ����բͨ��
      seqno     :=pPPOrderNo^.seqno;      //ָ�����
      //�Լ������ѯ����......... !!!!!
   finally
      Dispose(pPPOrderNo);
   end;

end;



end.
