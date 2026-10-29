"""Deliberately invalid stdio replies; test helper, never a CPS provider."""
import sys, time
scenario=sys.argv[1]
line=sys.stdin.readline()
request=line.split('\t')[0]
if scenario=='timeout': time.sleep(10)
elif scenario=='wrong_id': print('999\tOK',flush=True)
elif scenario=='duplicate': print(request+'\tOK\tx=YQ==\tx=Yg==',flush=True)
elif scenario=='base64': print(request+'\tOK\tx=%%%%',flush=True)
elif scenario=='truncated': sys.stdout.write(request+'\tOK');sys.stdout.flush()
elif scenario=='secret': print(request+'\tERR_SECRET-MUST-NOT-LEAK',flush=True)
elif scenario=='oversize': sys.stdout.write('x'*(8*1024*1024+1)+'\n');sys.stdout.flush()
