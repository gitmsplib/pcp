/*
 *------------------------------------------------------------------
 * test_version_negotiation.c
 *
 * March 13th, 2013, mbagljas
 *
 * Copyright (c) 2013-2013 by cisco Systems, Inc.
 * All rights reserved.
 *
 *------------------------------------------------------------------
 */


#include <stdio.h>
#include <stdlib.h>
#ifndef WIN32
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#endif
#include "pcp_socket.h"
#include "pcp.h"
#include "pcp_client_db.h"
#include "unp.h"
#include "test_macro.h"

int main(int argc, char *argv[]) {
    struct sockaddr_storage destination;
    struct sockaddr_storage source;
    struct sockaddr_storage ext;
    int version;
    pcp_server_t *s;
    uint8_t protocol = 6;
    uint32_t lifetime = 10;
    pcp_flow_t flow = NULL;
    pcp_flow_info_t * flow_info = NULL;
    size_t flow_count;

    PD_SOCKET_STARTUP();
    version = (argc == 2 ) ? (uint8_t)atoi(argv[1]) : PCP_MAX_SUPPORTED_VERSION;

    pcp_log_level = 0;

    if (argc != 2) {   //LCOV_EXCL_START
        printf("Invalid number of arguments.\n");
        printf("This test takes only one argument, PCP version number.\n");
        return -1;
    }  //LCOV_EXCL_STOP


    printf("\n");
    fprintf(stdout, "###########################################\n");
    printf("####   *****************************   ####\n");
    printf("####   * Begin version negotiation *   ####\n");
    printf("####   *           test            *   ####\n");
    printf("####   *****************************   ####\n");
    printf("###########################################\n");
    printf(">>> PCP server version =  %d \n", version);

    pcp_add_server(Sock_pton("127.0.0.1:5351"), version);

    sock_pton("127.0.0.1:1234", (struct sockaddr*) &destination);
    sock_pton("127.0.0.1:1235", (struct sockaddr*) &source);
    sock_pton("10.20.30.40", (struct sockaddr*) &ext);

    flow = pcp_new_flow((struct sockaddr*)&source,
                        (struct sockaddr*)&destination,
                        (struct sockaddr*)&ext,
                        protocol, lifetime);

    TEST(pcp_wait(flow, 2000, 0) == pcp_state_succeeded);
    pcp_flow_get_info(flow, &flow_info, &flow_count);
    TEST(flow_info);
    printf("Flow result code %d \n", flow_info->pcp_result_code);
    s = get_pcp_server(flow->pcp_server_indx);
    TEST((s) && (s->pcp_version == 1) );

    pcp_close_flow(flow);
    pcp_delete_flow(flow);
    flow = NULL;
    free(flow_info);

    PD_SOCKET_CLEANUP();
    pcp_terminate(0);
    return 0;

}
