######################################################################
# ??? - EDEN - ALL WHAT ARE HAVE BORN - LIVE AT EDGE ON HEAVEN -
######################################################################
FROM heaven:latest
# ######################################################################
RUN mkdir -p /anubis/src/eden && cd /anubis/src/eden && git clone https://github.com/lf-edge/eden .
# ######################################################################
RUN ls -la /anubis/src/eden/
# ######################################################################
RUN make clean && make build && make build-tests
####
# RUN cd /anubis/src/eden/ && make build 
# ####
# RUN cd /anubis/src/eden/ && eden config add default
# ####
# RUN cd /anubis/src/eden/ && eden setup
# ####
# ENTRYPOINT ['/docker-entrypoint.sh']
