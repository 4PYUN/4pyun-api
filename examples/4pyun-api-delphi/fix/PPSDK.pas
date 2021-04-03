unit PPSDK;


interface

CONST
  PYUNAPI_OPT_IDLE_TIME =$ffff;   //TCP�������ʱ��,��λmsint 300000
  PYUNAPI_OPT_READ_KEY  =$fffe;   //��������Կstring -
  PYUNAPI_OPT_WRITE_KEY =$fffd;   //д������Կstring -
  PYUNAPI_OPT_AUTH_TIME =$fffc;   //��֤��ʱʱ��,��λmsint 20000
  PYUNAPI_OPT_LOGGER    =$fffb;   //ָ��API��־�ļ�·��string ./4pyunapi.log
  PYUNAPI_OPT_CHARSET   =$fffa;   //������������string UTF-8
  PYUNAPI_OPT_DEV_MODE  =$fff9;   //������ģʽ: 1��, 0��int 0
  PYUNAPI_OPT_DEVICE    =$fff8;   //���豸ģʽ�����õ�ǰ�豸ID
  PYUNAPI_OPT_VENDOR    =$fff5;   //��ǰ�豸��Ӧ��

 type
    //event_type �ο� `PYUNAPI_EVENT_*` �Ķ��塣* msg ���Ŀǰevent_type������˵����
    TPYunAPIEventCallback  = procedure(event_type:Integer; Pmsg:PChar); stdcall;

    //* seqno �������, ��ԭ������ * payload ����JSON����
    TPYunAPIRequestCallback= Function (seqno:Integer;  payload :PChar) :Integer; stdcall;

 // 1.1 �����¼����ػص�����
 Procedure PYunAPIHookEvent  (PYunAPIEventCallback  :TPYunAPIEventCallback   );stdcall;external '4pyun-api.dll';  //�ص�

 // 1.2 ��������ص�
 Procedure PYunAPIHookRequest(PYunAPIRequestCallback:TPYunAPIRequestCallback ); stdcall; external '4pyun-api.dll';  //�ص�

 // 1.3 ���ÿ�ѡ��
 Function PYunAPISetOpt( optname : Integer;  optval :Pointer): Integer; stdcall; external '4pyun-api.dll';

 //2. ����API, �ײ�Ὺ���̺߳��ƶ˱���TCP������
{
* ��ʼ��API
* ����:
* host ��ƽ̨����
* port ��ƽ̨�˿�
* type �ͻ�������
* uuid �ͻ���UUID, һ��UUIDֻ������һ��ʵ��
* sign_mac �ӿ�ͨ��JSONǩ��������Կ
*
* ����ֵ:
* 0 ��ʼ�����
}
 Function  PYunAPIStart( phost :Pchar;  port :Integer;  ptype:Pchar; uuid:Pchar ; psign_mac :Pchar) : Integer; stdcall; external '4pyun-api.dll';

 //������ر�ʱ���ø÷������������رպ��ƶ����Ӳ��ͷ���Դ��
 procedure PYunAPIDestroy(); stdcall; external '4pyun-api.dll';


 //������������Ӧ
 Function PYunAPIReply( seqno :Integer; payload :Pchar) : Integer; stdcall; external '4pyun-api.dll';

implementation



end.
