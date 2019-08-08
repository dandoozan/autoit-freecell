f=open('c:/users/dan/dropbox/autoitPrograms/worldwinner/cards2.txt','r')
lines=f.readlines()
f.close()

s="["
for l in lines:
    s+="'"+l[:l.find('\t')]+"',"
print s
##f=open('c:/users/dan/dropbox/autoitPrograms/worldwinner/cards2.txt','r')
##lines2=f.readlines()
##f.close()

##for i in range(len(lines)):
##    split=lines[i].split('\t')
##    lines[i]=split[0]+'\t'+split[1]+'\t'+split[2]+'\t'+split[3]+'\t'+split[4]+'\t'+split[5]+'\t'+split[6]+'\t'+split[10]+'\t'+split[11]


##lines.sort()

##for j in range(1,12):
##    print j
##    lines2=[]
##    for l in lines:
##        split=l.strip().split('\t')
####        s=''
####        for k in range(1,12):
####            if k!=j:
####                s+=split[k]
##        s=split[1]+split[2]+split[3]+split[4]+split[5]+split[6]+split[10]+split[11]
##        lines2.append(s)
##
##    d={}
##    for i in range(len(lines2)):
##        try:
##            print d[lines2[i]],lines[i][:lines[i].find('\t')]
##        except:
##            pass
##        d[lines2[i]]=1
##    print

##d={}
##for l in lines:
##    try:
##        print d[l],l
##    except:
##        pass
##    d[l]=1

##f=open('c:/users/dan/dropbox/autoitPrograms/worldwinner/cards.txt','w')
##for l in lines:
##    split=l.split('\t')
##    s=''
##    for i in range(1,len(split)):
##        s+=split[i]
##    f.write(s)
##f.close()

