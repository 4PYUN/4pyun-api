// api-demo.cpp : �������̨Ӧ�ó������ڵ㡣
//

#include "stdafx.h"
#include <stdio.h>
#include <stdlib.h>
#include "4pyun-api.h"
#include <windows.h>
#include <time.h>

/**
 * API�¼��ص�����ʵ��
 */
void __stdcall PYunAPIEventCallback(int event_type, char *msg){  
	switch (event_type) {
		case PYUNAPI_EVENT_ACCESS_GRANTED:
			printf("\nAccessGranted %s\n\n", msg == NULL ? "" : msg);
			break;
		case PYUNAPI_EVENT_ACCESS_DENIED:
			printf("\nAccessDenied %s\n\n", msg == NULL ? "" : msg);
			break;
		case PYUNAPI_EVENT_CHANNEL_ERROR:
			printf("\nChannelError %s\n\n", msg == NULL ? "" : msg);
			break;
		case PYUNAPI_EVENT_CHANNEL_CLOSED:
			printf("\nChannelClosed %s\n\n", msg == NULL ? "" : msg);
			break;
	}
}

int __stdcall PYunAPIRequestCallback(int seqno, char *payload) {
    // ����JSON�е�service�ж��Ƿ���, ���û����ret����Ϊ-1��
	int ret = 0;

	printf("RECV: %d, %s\n", seqno, payload);
	char *reply = "{\"charset\":\"UTF-8\",\"result_code\":\"1002\",\"message\":\"��Ϣ����\",\"key1\":\"value1\",\"key2\":\"value2\",\"service\":\"service.parking.payment.billing\",\"version\":\"1.0\"}";
	//Sleep(3000);
	// Reply��ʱ�����ԭ������seqno!
	PYunAPIReply(seqno, reply);
	return ret;
}

int _tmain(int argc, _TCHAR* argv[])
{
	int idle_time = 1000 * 1;
	int auth_time = 1000 * 30;
	int dev_mode = 1;
	char *host = "sandbox.gate.4pyun.com";

	unsigned int port = 8661;
	char *type = "public:parking:agent";
	char *uuid = "49f0cc52-e8c7-41e3-b54d-af666b8cc11a";
	char *sign_mac = "123";
	char *device = "A,B,C";
	// ��ǰ�Խ�ϵͳ��Ӧ�̱�ʶ, ��P�Ʒ��䲢д���ڴ�����!
	char *vendor = "PYUN";
	// ��ǰ��������, ���豸����������������
	char *hostname = "PC-1";
	// ��ǰ��������IP, ���豸����������������
	char *host_address = "192.168.6.99";
	// �����豸Ӳ��ָ��, ��ֹ�������á�
	char *fingerprint = "ABCD";

	char *version = PYunAPIVersion();
	printf("SDK_VER: %s\n", version);
	getchar();

	// !!!!!!!��ȡSDK API�ȼ�, ����ִ���������!!!!!!!
	int sdk_level = PYunAPILevel();
	printf("SDK_LEVEL: %d\n", sdk_level);
	getchar();
	if (sdk_level < 10) {
		// ���͵�SDK�汾
		return -1;
	}

	// 243264PEIT6SHEOB8IC8GI => 13571,3503
	char dest2[2048] = {0};
	char *input = "243264PEIT6SHEOB8IC8GI";
	printf("CRC CALC INPUT=%s\n", input);
	printf("###########################\n");
	PYunAPICryptoCRC(input, dest2, PYUNAPI_CRYPTO_CRC16_ARC);
	printf("CRC16_ARC        : %s\n", dest2);
	PYunAPICryptoCRC(input, dest2, PYUNAPI_CRYPTO_CRC16_MODBUS);
	printf("CRC16_MODBUS     : %s\n", dest2);
	PYunAPICryptoCRC(input, dest2, PYUNAPI_CRYPTO_CRC16_USB);
	printf("CRC16_USB        : %s\n", dest2);
	PYunAPICryptoCRC(input, dest2, PYUNAPI_CRYPTO_CRC16_DNP);
	printf("CRC16_DNP        : %s\n", dest2);
	PYunAPICryptoCRC(input, dest2, PYUNAPI_CRYPTO_CRC16_CCCT_FALSE);
	printf("CRC16_CCCT_FALSE : %s\n", dest2);
	PYunAPICryptoCRC(input, dest2, PYUNAPI_CRYPTO_CRC16_XMODEM);
	printf("CRC16_XMODEM     : %s\n", dest2);
	getchar();

	// TEST MEMCPY
	char dest[2048] = {0};
	PYunAPIMemcpy("Hello", dest);
	printf("Memcpy: %s\n", dest);
	getchar();
	
	// TEST MD5...
	input = "����ABC123";
	char *hash = (char *) malloc(33);
	PYunAPICryptoMD5(input, hash);
	printf("MD5: %s\n", hash);
	getchar();

	// 1.1 �����¼����ػص�����
	PYunAPIHookEvent(PYunAPIEventCallback);
	// 1.2 ��������ص�
	PYunAPIHookRequest(PYunAPIRequestCallback);

	do {
		// ȡ��ǰ����������־�ļ�����, SDK�ײ㲻���Զ��ָ���־�ļ��������ϲ�Ӧ��ÿ�������µ���־�ļ�����
		char time_buf[26];
		time_t timer = time(0);
		strftime(time_buf, 26, "%Y%m%d", localtime(&timer));
		char logger_file_name[128] = { 0 };
		sprintf(logger_file_name, "C://logs/4pyun-api.%s.log", time_buf);
		printf("LOG_FILE: %s\n", logger_file_name);

		// 1.3 ���ÿ�ѡ��
		// [����]���õ�ǰ��Ŀ���̱���, �ײ�Ĭ��UTF-8����
		PYunAPISetOpt(PYUNAPI_OPT_CHARSET,   (void *)"GBK");
		// [��ѡ]�������ģʽ, Ĭ���ڵ�ǰִ��Ŀ¼������־�ļ�
		PYunAPISetOpt(PYUNAPI_OPT_DEV_MODE,   (void *)&dev_mode);

		printf("DEV_MODE: %d\n", PYunAPIGetOpt(PYUNAPI_OPT_DEV_MODE));

		// [��ѡ]�����������ʱ��, ms
	//	PYunAPISetOpt(PYUNAPI_OPT_IDLE_TIME, (void *)&idle_time);
		// [��ѡ]������Ȩ��ʱʱ��, ms
		PYunAPISetOpt(PYUNAPI_OPT_AUTH_TIME, (void *)&auth_time);
		// [��ѡ]������־�ļ�
		PYunAPISetOpt(PYUNAPI_OPT_LOGGER, (void *)&logger_file_name);
		// [��ѡ]�����豸ID, ���ڶ��ն�ģʽ������
		PYunAPISetOpt(PYUNAPI_OPT_DEVICE, (void *)device);
		// [��ѡ]���õ�ǰ�Խ�ϵͳ��Ӧ�̱�ʶ, ��P�Ʒ��䲢д���ڴ�����
		PYunAPISetOpt(PYUNAPI_OPT_VENDOR, (void *)vendor);
		// [��ѡ]���ü����豸Ӳ��ָ��, ��ֹ�������á�
		PYunAPISetOpt(PYUNAPI_OPT_FINGERPRINT, (void *)fingerprint);
		// [��ѡ]���õ�ǰ������������
		PYunAPISetOpt(PYUNAPI_OPT_HOST_NAME, (void *)hostname);
		// [��ѡ]���õ�ǰ��������IP
		PYunAPISetOpt(PYUNAPI_OPT_HOST_ADDR, (void *)host_address);

		// 2. ����API, �ײ�Ὺ���̺߳��ƶ˱���TCP������
		PYunAPIStart(host, port, type, uuid, sign_mac);

		getchar();
		// 3. ����API, �Ͽ�TCP������
		PYunAPIDestroy();
	} while (true);

	return 0;
}

