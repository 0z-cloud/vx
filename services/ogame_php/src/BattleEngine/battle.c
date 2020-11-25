// ������ ������ ���������� ���� OGame.

/*
������� ���

������� ��� ������ ���������� � ��� �������, ����� ��������� ����� ����������� � �����-���� ������� ��� ����.
��� ��������� � �������� ��� ���������, �� � ��� ����� ��������, ��� ������� ���� ��� ���������.
� ���� ������ ������ ������� ������������� � �������� ������ ���� �� �����. ��� ���������� 6 ��� (6 �������).
��� � ����� ������� � ���������, ��� ����������. ���� � ����� �� ����� �������� �������� �����, �� ��� ������������� ������ � ���������� ������������ �����.
� ������ ������ ������� � �������� ���������� �������� ���� �� �����. ��� ���� ������ ���� �������� ���� ��� (����������: ����������) �� �������� ��������� ����.
������� ���� �������� ������������ ������� �����. ��� ���� ����������� �������� ��� ��������� ������. ���� ����� ����� ��� ���-�� ������� �� ������ ����, �� ��� ���������� �� ����� �������.
�������� ����� �������� ���� �� �������� � ��������� ������������ ������. � ����� ������ ���������� �������, � ������� ������ �� �������� �����.
�� � �� 30% ����������� ����� ���� ������� ���� ������, ������� ����� ������ �� �������� �����������.
���� ��������:
������ ���� ����� ��������� ���� ��������. Ÿ ����� ��������� ������������� ��������� ������� �� 10% �� �������.
��������: ������ ����������� ����� ������ ����� 150. ��������� ������� ������ 10 �������� ��� �� 100% �� ���� �� 300.
��� ��� ������ ���� ���� ������ ������������ ������.
����:
���� ������� ��������� ���� �� ����, ����������� ����� �� �����������. ������ ����� ��� ���� ����������, ���������� ����������� �����.
���� ����� ���� �������� ������������� ������� ���������� �� 10% �� ������� ������������.
���� ��������� ����������������� ����� ������� ������. ������ ������ ��� ������������ ������ �������� �� 1%, � ������� ���� ����� ����� 1% ����������� ��� �����-���� ������.
��������, ���� ���� �������� ������� �� 3.7% ����, ����� ���������� ���� 3%, � 0.7% ����������. ������� �������� � ����� ����� 1%, ����������� �� �����, �� �������� �� ���� � �� ������ ����� �����.
����������� ������ � ���� ������ ����� �� �������������.
������: ����� ����������� (����� 50) �������� �� �������� ������ (��� 10000). ����� �������� � ������ �� ��� 10000 �����, ��� ��� ������� ������� ���� � ��� ��� ��������� ���������.
������ �� ����������� ����� ���� �������� 150. ��� 1.5% �� ����, ������� ������� ������������� � �� ���� ��������� ����� ����� ����� - 1%.
����� ����� � ������ ������� ���� ����� ������ 9900, ��� ��� 0.5% = 50 ����� ��������� ����� ��� ������.
�����:
����� ���������, ����� ����� ������� ����� ���������, ������ ��� �� ����� ���������. ����� ����� ������ ���������� 10% ���������.
�� ����� ��������� ��� ��� ��������� �����. �� ������ 10 ������� ��� ��������� (���� ����� �� ���������) ���������� 1 ����� �����.
���� ����� ����� ������������� ������������� ����� ����������� �������� �� 10% �� �������. � ���������, ������� ������� � ��������� ��� �� 30% ����������� �����.
����� ��� ������������ ������ ������. ������������ ����������: ���� ����� ����������� ���� ���������� � ������ 2-� �������.
����� ���������� �������� ������ �������� ���������. �������� �������� ������ ������
������� ���������
���� ������� ��������� ����� ��������, � ������ ����� ������� � ������ ������� �� ��������: ����� �������, ������ �������, ����� ������, ������ ������.
����� ����
���� ���������� ��������� ��������. ����� ����, ��� ��� ����� ����� �� ����� ����, ���� ���� � ������ ����, �� ��� ������������.
������ ������ ���� ���, ��� �����, ������� ������ �����, �������� ������ ���� ���������. ��� ���� � ������� ������� � ��������� ���������� ���� �����������, ��� � ���� �������, ������ 1/(���-�� ���� ������)
�������������� ������:
�������� ���������� ����� ����������� �� �������������� ����� ��� � 70%.
��� ��������� ���������� ������ (������ ��� 10) ��� ����������� ������������� ��� ������� ���������� ��������.
��� ������� ���������� ����������� ������������� ��� ������� ���� ������. ��� ���� ����������������� ������ 70% +/-10% ����������� ������.
��� 10 �������� ���������� ��� ������� 6 � �������� 8 ��������������� ��. ������� ����� ��������� �����������. ��� ������� ���� ������ ����������� ������������� ��������.
�� ����, ��������, �� � ������ �� ������������ ������. 

����������              
������ ���������� �������� ����������� ��������� ����� �������� ����������� �� ����� ����� ������������ �������� ��� ������ ��������. 
����������� ���������� �������� ���������� � ������� �� ����� ����������� ������� � ���� ��������. ������ ����������� ����������� � �������������� ����������� ���������� �������� ��� - ��� � ���� - ������� ����������� ��������� �� ���� �����.
� ������� ���������� �������� ��������� �������:
�������, ������� �� �����, ������ �������� � ���� ���� ����������, � ����������� ������������ �������� ��� ���, � ������������ � �������� ��� - �� ��������� ������� ����.
��� ��������� ��������� � ����� ������ �������, ����� "��������� ������" � ���� ������, ���������� ��� ���� �������. 
<�������� � ���������� ������� �������� ����������� �� http://board.ogame.ru/index.php?page=Thread&threadID=47130 >
*/

/*
���������� ������.

������ ������������ ����� ������ ����. �� ���� �������� ��������� ������� (���������� �� �����):
- ��������� ������ ������� (������� ������� � ����� � �������, ����������)
- ������ ��������� � ������������� 

�� ������ ������ ����������:
- ���������� ��� (������������ � �������� ����)
*/

// ��� ���� ����� ������ �������� ��������� � ���� ���� (��� �������� ������), ��������� ����� ���������� �� 100 (������ 202), � ������� �� 200 (������ 401).

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <math.h>
#include "battle.h"

/*
������ �������� ������
�������� ������ ������������ � ������� ��� PHP-������� unserialize().

������ (����� �������������� unserialize()):

Array (
   'result' => 'awon' (��������� �������), 'dwon' (������������� �������), 'draw' (�����)
   'dm' => ���������� ������� � ���� ��������
   'dk' => ���������� ��������� � ���� ��������

   'before' => Array (  // ����� ����� ����
            'attackers' => Array (    // ����� ���������
                  [0] => Array ( 'name' => ��� ������, 'id'=>100002, 'g' => 1, 's' => 2 'p' => 3, 'weap' => 10, 'shld' => 11, 'armr' => 12, 202=>5, 203=>6, ... ),   // �����
                  [1] => Array ( )
            )

            'defenders' => Array (    // ����� �������������
                  [0] => Array ( 'name' => ��� ������, 'id'=>100006, 'g' => 1, 's' => 2 'p' => 3, 'weap' => 10, 'shld' => 11, 'armr' => 12, 202=>5, 203=>6, ..., 401=>5, 402=>44 ),   // ����� � �������
                  [1] => Array ( )
            )

       ),
   )

   'rounds' => Array (  // ������
       [0] => Array (
            'ashoot' => ��������� ���� ������: 988 ��������(��)
            'apower' => ����� ��������� 512.720.100
            'dabsorb' => ���� �������������� ��������� 43.724
            'dshoot' => ������������� ���� ������ 1.651 ��������(��)
            'dpower' => ����� ��������� 428.728
            'aabsorb' => ���� ���������� ��������� 355.453

            'attackers' => Array (    // ����� ���������
                  [0] => Array ( 'name' => ��� ������, 'id'=>100002, 'g' => 1, 's' => 2 'p' => 3, 202=>5, 203=>6, ... ),   // �����
                  [1] => Array ( )
            )

            'defenders' => Array (    // ����� �������������
                  [0] => Array ( 'name' => ��� ������, 'id'=>100006, 'g' => 1, 's' => 2 'p' => 3, 202=>5, 203=>6, ..., 401=>5, 402=>44 ),   // ����� � �������
                  [1] => Array ( )
            )

       ),
       [1] => Array ( ... )   // ��������� �����
   )
)

*/

char ResultBuffer[64*1024];     // ����� �������� ������.

// ��������� ��������� ����.
int DefenseInDebris = 0, FleetInDebris = 30;
int Rapidfire = 1;  // 1: ��� �������� ���������.

// ������� ���������.
typedef struct UnitPrice { long m, k, d; } UnitPrice;
static UnitPrice FleetPrice[] = {
 { 2000, 2000, 0 }, { 6000, 6000, 0 }, { 3000, 1000, 0 }, { 6000, 4000, 0 },
 { 20000, 7000, 2000 }, { 45000, 15000, 0 }, { 10000, 20000, 10000 }, { 10000, 6000, 2000 },
 { 0, 1000, 0 }, { 50000, 25000, 15000 }, { 0, 2000, 500 }, { 60000, 50000, 15000 },
 { 5000000, 4000000, 1000000 }, { 30000, 40000, 15000 }
};
static UnitPrice DefensePrice[] = {
 { 2000, 0, 0 }, { 1500, 500, 0 }, { 6000, 2000, 0 }, { 20000, 15000, 2000 },
 { 2000, 6000, 0 }, { 50000, 50000, 30000 }, { 10000, 10000, 0 }, { 50000, 50000, 0 }
};

TechParam fleetParam[14] = { // ��� �����.
 { 4000, 10, 5, 5000 },
 { 12000, 25, 5, 25000 },
 { 4000, 10, 50, 50 },
 { 10000, 25, 150, 100 },
 { 27000, 50, 400, 800 },
 { 60000, 200, 1000, 1500 },
 { 30000, 100, 50, 7500 },
 { 16000, 10, 1, 20000 },      
 { 1000, 0, 0, 0 },
 { 75000, 500, 1000, 500 },
 { 2000, 1, 1, 0 },
 { 110000, 500, 2000, 2000 }, 
 { 9000000, 50000, 200000, 1000000 }, 
 { 70000, 400, 700, 750 }
};

TechParam defenseParam[8] = { // ��� �������.
 { 2000, 20, 80, 0 },
 { 2000, 25, 100, 0 },
 { 8000, 100, 250, 0 },
 { 35000, 200, 1100, 0 },
 { 8000, 500, 150, 0 },
 { 100000, 300, 3000, 0 },
 { 20000, 2000, 1, 0 },
 { 100000, 10000, 1, 0 },
};

// ==========================================================================================

// load data from file
void * FileLoad(char *filename, unsigned long *size, char * mode)
{
    FILE*   f;
    void*   buffer;
    unsigned long     filesize;

    if(size) *size = 0;

    f = fopen(filename, mode);
    if(f == NULL) return NULL;

    fseek(f, 0, SEEK_END);
    filesize = ftell(f);
    fseek(f, 0, SEEK_SET);

    buffer = malloc(filesize + 10);
    if(buffer == NULL)
    {
        fclose(f);
        return NULL;
    }
    memset ( buffer, 0, filesize+10);

    fread(buffer, filesize, 1, f);
    fclose(f);
    if(size) *size = filesize;    
    return buffer;
}

// save data in file
int FileSave(char *filename, void *data, unsigned long size)
{
    FILE *f = fopen(filename, "wt");
    if(f == NULL) return 0;

    fwrite(data, size, 1, f);
    fclose(f);
    return 1;
}

// ==========================================================================================
// ��������� ��������� �����.
// Mersenne Twister.

#define N 624
#define M 397
#define MATRIX_A 0x9908b0dfUL
#define UPPER_MASK 0x80000000UL
#define LOWER_MASK 0x7fffffffUL

static unsigned long mt[N];
static int mti=N+1;

void init_genrand(unsigned long s)
{
    mt[0]= s & 0xffffffffUL;
    for (mti=1; mti<N; mti++) {
        mt[mti] = 
        (1812433253UL * (mt[mti-1] ^ (mt[mti-1] >> 30)) + mti); 
        mt[mti] &= 0xffffffffUL;
    }
}

unsigned long genrand_int32(void)
{
    unsigned long y;
    static unsigned long mag01[2]={0x0UL, MATRIX_A};

    if (mti >= N) {
        int kk;

        if (mti == N+1)
            init_genrand(5489UL);

        for (kk=0;kk<N-M;kk++) {
            y = (mt[kk]&UPPER_MASK)|(mt[kk+1]&LOWER_MASK);
            mt[kk] = mt[kk+M] ^ (y >> 1) ^ mag01[y & 0x1UL];
        }
        for (;kk<N-1;kk++) {
            y = (mt[kk]&UPPER_MASK)|(mt[kk+1]&LOWER_MASK);
            mt[kk] = mt[kk+(M-N)] ^ (y >> 1) ^ mag01[y & 0x1UL];
        }
        y = (mt[N-1]&UPPER_MASK)|(mt[0]&LOWER_MASK);
        mt[N-1] = mt[M-1] ^ (y >> 1) ^ mag01[y & 0x1UL];

        mti = 0;
    }
  
    y = mt[mti++];

    y ^= (y >> 11);
    y ^= (y << 7) & 0x9d2c5680UL;
    y ^= (y << 15) & 0xefc60000UL;
    y ^= (y >> 18);

    return y;
}

double genrand_real1(void) { return genrand_int32()*(1.0/4294967295.0); }
double genrand_real2(void) { return genrand_int32()*(1.0/4294967296.0); }

// ������������ ��������������� ������������������.
void MySrand (unsigned long seed)
{
    init_genrand (seed);
    //srand (seed);
}

// ���������� ��������� ����� � ��������� �� a �� b (������� a � b)
unsigned long MyRand (unsigned long a, unsigned long b)
{
    return a + (unsigned long)(genrand_real1 () * (b - a + 1));
    //return a + (unsigned long)((rand ()*(1.0/RAND_MAX)) * (b - a + 1));
}

// ==========================================================================================

static char *longnumber (u64 n)
{
    static char retbuf [32];
    char *p = &retbuf [sizeof (retbuf) - 1];
    int i = 0;

    if (n == 0) return "0";
    *p = '\0';
    for (i = 0; n; i++)
    {
        *--p = '0' + n % 10;
        n /= 10;
    }
    return p;
}

// ���������� ��������� ��������� ����.
void SetDebrisOptions (int did, int fid)
{
    if (did < 0) did = 0;
    if (fid < 0) fid = 0;
    if (did > 100) did = 100;
    if (fid > 100) fid = 100;
    DefenseInDebris = did;
    FleetInDebris = fid;
}

void SetRapidfire (int enable) { Rapidfire = enable & 1; }

// �������� ������ ��� ������ � ���������� ��������� ��������.
Unit *InitBattleAttackers (Slot *a, int anum, int objs)
{
    Unit *u;
    int aid = 0;
    int i, n, ucnt = 0, obj;
    u = (Unit *)malloc (objs * sizeof(Unit));
    if (u == NULL) return u;
    memset (u, 0, objs * sizeof(Unit));
    
    for (i=0; i<anum; i++, aid++) {
        for (n=0; n<14; n++)
        {
            for (obj=0; obj<a[i].fleet[n]; obj++) {
                u[ucnt].hull = u[ucnt].hullmax = fleetParam[n].structure * 0.1 * (10+a[i].armor) / 10;
                u[ucnt].obj_type = 100 + n;
                u[ucnt].slot_id = aid;
                ucnt++;
            }
        }
    }

    return u;
}

Unit *InitBattleDefenders (Slot *d, int dnum, int objs)
{
    Unit *u;
    int did = 0;
    int i, n, ucnt = 0, obj;
    u = (Unit *)malloc (objs * sizeof(Unit));
    if (u == NULL) return u;
    memset (u, 0, objs * sizeof(Unit));

    for (i=0; i<dnum; i++, did++) {
        for (n=0; n<14; n++)
        {
            for (obj=0; obj<d[i].fleet[n]; obj++) {
                u[ucnt].hull = u[ucnt].hullmax = fleetParam[n].structure * 0.1 * (10+d[i].armor) / 10;
                u[ucnt].obj_type = 100 + n;
                u[ucnt].slot_id = did;
                ucnt++;
            }
        }
        for (n=0; n<8; n++)
        {
            for (obj=0; obj<d[i].def[n]; obj++) {
                u[ucnt].hull = u[ucnt].hullmax = defenseParam[n].structure * 0.1 * (10+d[i].armor) / 10;
                u[ucnt].obj_type = 200 + n;
                u[ucnt].slot_id = did;
                ucnt++;
            }
        }
    }

    return u;
}

// ������� a => b. ���������� ����. aweap - ������� ��������� ���������� ��� ����� "a".
// absorbed - ���������� ������������ ������ ����� (��� ����, ���� �������, �� ���� ��� ����� "b").
long UnitShoot (Unit *a, int aweap, Unit *b, u64 *absorbed, u64 *dm, u64 *dk )
{
    float prc, depleted;
    long apower, adelta = 0;
    if (a->obj_type < 200) apower = fleetParam[a->obj_type-100].attack * (10+aweap) / 10;
    else apower = defenseParam[a->obj_type-200].attack * (10+aweap) / 10;

    if (b->exploded) return apower; // ��� �������.
    if (b->shield == 0) {  // ����� ���.
        if (apower >= b->hull) b->hull = 0;
        else b->hull -= apower;
    }
    else { // �������� �� �����, � ���� ������� �����, �� � �� �����.
        prc = (float)b->shieldmax * 0.01;
        depleted = floor ((float)apower / prc);
        if (b->shield < (depleted * prc)) {
            *absorbed += (u64)b->shield;
            adelta = apower - b->shield;
            if (adelta >= b->hull) b->hull = 0;
            else b->hull -= adelta;
            b->shield = 0;
        }
        else {
            b->shield -= depleted * prc;
            *absorbed += (u64)apower;
        }
    }
    if (b->hull <= b->hullmax * 0.7 && b->shield == 0) {    // �������� � �������� ����.
        if (MyRand (0, 99) >= ((b->hull * 100) / b->hullmax) || b->hull == 0) {
            if (b->obj_type >= 200) {
                *dm += (u64)(ceil(DefensePrice[b->obj_type-200].m * ((float)DefenseInDebris/100.0f)));
                *dk += (u64)(ceil(DefensePrice[b->obj_type-200].k * ((float)DefenseInDebris/100.0f)));
            }
            else {
                *dm += (u64)(ceil(FleetPrice[b->obj_type-100].m * ((float)FleetInDebris/100.0f)));
                *dk += (u64)(ceil(FleetPrice[b->obj_type-100].k * ((float)FleetInDebris/100.0f)));
            }
            b->exploded = 1;
        }
    }
    return apower;
}

// ��������� ���������� ������� � �������. ���������� ���������� ���������� ������.
int WipeExploded (Unit **slot, int amount)
{
    Unit *src = *slot, *tmp;
    int i, p = 0, exploded = 0;
    tmp = (Unit *)malloc (sizeof(Unit) * amount);
    for (i=0; i<amount; i++) {
        if (!src[i].exploded) tmp[p++] = src[i];
        else exploded++;
    }
    free (src);
    *slot = tmp;
    return exploded;
}

// ��������� ��� �� ������� �����. ���� �� � ������ ����� ����� �� ����������, �� ��� ������������� ������ ��������.
int CheckFastDraw (Unit *aunits, int aobjs, Unit *dunits, int dobjs)
{
    int i;
    for (i=0; i<aobjs; i++) {
        if (aunits[i].hull != aunits[i].hullmax) return 0;
    }
    for (i=0; i<dobjs; i++) {
        if (dunits[i].hull != dunits[i].hullmax) return 0;
    }
    return 1;
}

// ������������� HTML-��� �����.
// ���� techs = 1, �� �������� ���������� (� ������� ���������� ���������� �� ����).
static char * GenSlot (char * ptr, Unit *units, int slot, int objnum, Slot *a, Slot *d, int attacker, int techs)
{
    Slot *s = attacker ? a : d;
    Slot coll;
    Unit *u;
    int n, i, count = 0;
    unsigned long sum = 0;

    // ������� ��� ����� � ����.
    memset (&coll, 0, sizeof(Slot));
    for (i=0; i<objnum; i++) {
        u = &units[i];
        if (u->slot_id == slot) {
            if (u->obj_type < 200) { coll.fleet[u->obj_type-100]++; sum++; }
            else { coll.def[u->obj_type-200]++; sum++; }
        }
    }

    if ( techs ) {
        if ( attacker) ptr += sprintf ( ptr, "i:%i;a:22:{", slot );
        else ptr += sprintf ( ptr, "i:%i;a:30:{", slot );
    }
    else {
        if ( attacker) ptr += sprintf ( ptr, "i:%i;a:19:{", slot );
        else ptr += sprintf ( ptr, "i:%i;a:27:{", slot );
    }

    ptr += sprintf (ptr, "s:4:\"name\";s:%i:\"%s\";", strlen(s[slot].name), s[slot].name );
    ptr += sprintf (ptr, "s:2:\"id\";i:%i;", s[slot].id );
    ptr += sprintf (ptr, "s:1:\"g\";i:%i;", s[slot].g );
    ptr += sprintf (ptr, "s:1:\"s\";i:%i;", s[slot].s );
    ptr += sprintf (ptr, "s:1:\"p\";i:%i;", s[slot].p );

    if ( techs ) {
        ptr += sprintf (ptr, "s:4:\"weap\";i:%i;", s[slot].weap );
        ptr += sprintf (ptr, "s:4:\"shld\";i:%i;", s[slot].shld );
        ptr += sprintf (ptr, "s:4:\"armr\";i:%i;", s[slot].armor );
    }

    for (n=0; n<14; n++) {      // �����
        ptr += sprintf ( ptr, "i:%i;i:%i;", 202+n, coll.fleet[n]);
    }

    if ( !attacker)             // �������
    {
        for (n=0; n<8; n++) {
            ptr += sprintf ( ptr, "i:%i;i:%i;", 401+n, coll.def[n]);
        }
    }

    ptr += sprintf ( ptr, "}" );
    return ptr;
}

static int RapidFire (int atyp, int dtyp)
{
    int rapidfire = 0;

    if ( atyp > 400 ) return 0;

    // ���� ������ ��/����
    if (atyp==214 && (dtyp==210 || dtyp==212) && MyRand(1,10000)>8) rapidfire = 1;
    // ��������� ���� ������ ��/����
    else if (atyp!=210 && (dtyp==210 || dtyp==212) && MyRand(1,100)>20) rapidfire = 1;
    // �� ������ ��
    else if (atyp==205 && dtyp==202 && MyRand(1,100)>33) rapidfire = 1;
    // ������� ������ ��
    else if (atyp==206 && dtyp==204 && MyRand(1,1000)>166) rapidfire = 1;
    // ������� ������ ��
    else if (atyp==206 && dtyp==401 && MyRand(1,100)>10) rapidfire = 1;
    // ������ ������ ������ �������
    else if (atyp==211 && (dtyp==401 || dtyp==402) && MyRand(1,100)>20) rapidfire = 1;
    // ������ ������ ������� �������
    else if (atyp==211 && (dtyp==403 || dtyp==405) && MyRand(1,100)>10) rapidfire = 1;
    // ���� ������ ��
    else if (atyp==213 && dtyp==215 && MyRand(1,100)>50) rapidfire = 1;
    // ���� ������ ��
    else if (atyp==213 && dtyp==402 && MyRand(1,100)>10) rapidfire = 1;
    // �� ������ ����������
    else if (atyp==215 && (dtyp==202 || dtyp==203) && MyRand(1,100)>20) rapidfire = 1;
    // �� ������ �������� �����
    else if (atyp==215 && (dtyp==205 || dtyp==206) && MyRand(1,100)>25) rapidfire = 1;
    // �� ������ ��������
    else if (atyp==215 && dtyp==207 && MyRand(1,1000)>143) rapidfire = 1;
    // �� ������ ������������ �����
    else if (atyp==214 && (dtyp==202 || dtyp==203 || dtyp==208 || dtyp==209) && MyRand(1,1000)>4) rapidfire = 1;
    // �� ������ ��
    else if (atyp==214 && dtyp==204 && MyRand(1,1000)>5) rapidfire = 1;
    // �� ������ ��
    else if (atyp==214 && dtyp==205 && MyRand(1,1000)>10) rapidfire = 1;
    // �� ������ ���������
    else if (atyp==214 && dtyp==206 && MyRand(1,1000)>30) rapidfire = 1;
    // �� ������ ��������
    else if (atyp==214 && dtyp==207 && MyRand(1,1000)>33) rapidfire = 1;
    // �� ������ ��������
    else if (atyp==214 && dtyp==211 && MyRand(1,1000)>40) rapidfire = 1;
    // �� ������ ������
    else if (atyp==214 && dtyp==213 && MyRand(1,1000)>200) rapidfire = 1;
    // �� ������ ������
    else if (atyp==214 && dtyp==215 && MyRand(1,1000)>66) rapidfire = 1;
    // �� ������ ������ �������
    else if (atyp==214 && (dtyp==401 || dtyp==402) && MyRand(1,1000)>5) rapidfire = 1;
    // �� ������ ������� �������
    else if (atyp==214 && (dtyp==403 || dtyp==405) && MyRand(1,1000)>10) rapidfire = 1;
    // �� ������ ������� �������
    else if (atyp==214 && dtyp==404 && MyRand(1,1000)>20) rapidfire = 1;

    return rapidfire;
}

int DoBattle (Slot *a, int anum, Slot *d, int dnum)
{
    long slot, i, n, aobjs = 0, dobjs = 0, idx, rounds, sum = 0;
    long apower, atyp, dtyp, rapid, rapidfire, rapidchance, fastdraw;
    Unit *aunits, *dunits, *unit;
    char * ptr = ResultBuffer, * res, *round_patch;

    u64         shoots[2], spower[2], absorbed[2]; // ����� ���������� �� ���������.    
    u64         dm = 0, dk = 0;             // ���� ��������

    // ��������� ����������� ������ �� ���.
    for (i=0; i<anum; i++) {
        for (n=0; n<14; n++) aobjs += a[i].fleet[n];
    }
    for (i=0; i<dnum; i++) {
        for (n=0; n<14; n++) dobjs += d[i].fleet[n];
        if (i == 0) {
            for (n=0; n<8; n++) dobjs += d[i].def[n];
        }
    }

    // ����������� ������ ������ ������.
    aunits = InitBattleAttackers (a, anum, aobjs);
    if (aunits == NULL) {
        return 0;
    }
    dunits = InitBattleDefenders (d, dnum, dobjs);
    if (dunits == NULL) {
        return 0;
    }

    ptr += sprintf (ptr, "a:5:{");

    // ����� �� ���
    ptr += sprintf (ptr, "s:6:\"before\";a:2:{");
    ptr += sprintf ( ptr, "s:9:\"attackers\";a:%i:{", anum );
    for (slot=0; slot<anum; slot++) {
        ptr = GenSlot (ptr, aunits, slot, aobjs, a, d, 1, 1);
    }
    ptr += sprintf ( ptr, "}" );
    ptr += sprintf ( ptr, "s:9:\"defenders\";a:%i:{", dnum );
    for (slot=0; slot<dnum; slot++) {
        ptr = GenSlot (ptr, dunits, slot, dobjs, a, d, 0, 1);
    }
    ptr += sprintf ( ptr, "}" );
    ptr += sprintf ( ptr, "}" );

    round_patch = ptr + 15;
    ptr += sprintf (ptr, "s:6:\"rounds\";a:X:{");

    for (rounds=0; rounds<6; rounds++)
    {
        if (aobjs == 0 || dobjs == 0) break;

        // �������� ����������.
        shoots[0] = shoots[1] = 0;
        spower[0] = spower[1] = 0;
        absorbed[0] = absorbed[1] = 0;

        // �������� ����.
        for (i=0; i<aobjs; i++) {
            if (aunits[i].exploded) aunits[i].shield = aunits[i].shieldmax = 0;
            else aunits[i].shield = aunits[i].shieldmax = fleetParam[aunits[i].obj_type-100].shield * (10+a[aunits[i].slot_id].shld) / 10;
        }
        for (i=0; i<dobjs; i++) {
            if (dunits[i].exploded) dunits[i].shield = dunits[i].shieldmax = 0;
            else {
                if (dunits[i].obj_type >= 200) dunits[i].shield = dunits[i].shieldmax = defenseParam[dunits[i].obj_type-200].shield * (10+d[dunits[i].slot_id].shld) / 10;
                else dunits[i].shield = dunits[i].shieldmax = fleetParam[dunits[i].obj_type-100].shield * (10+d[dunits[i].slot_id].shld) / 10;
            }
        }

        // ���������� ��������.
        for (slot=0; slot<anum; slot++)     // ���������
        {
            for (i=0; i<aobjs; i++) {
                rapidfire = 1;
                unit = &aunits[i];
                if (unit->slot_id == slot) {
                    // �������.
                    while (rapidfire) {
                        idx = MyRand (0, dobjs-1);
                        apower = UnitShoot (unit, a[slot].weap, &dunits[idx], &absorbed[1], &dm, &dk );
                        shoots[0]++;
                        spower[0] += apower;

                        // ��������� ID � ������� ������, ����� ���� ��������.
                        atyp = unit->obj_type;
                        if ( atyp < 200 ) atyp += 102;
                        else atyp += 201;
                        dtyp = dunits[idx].obj_type;
                        if ( dtyp < 200 ) dtyp += 102;
                        else dtyp += 201;
                        rapidfire = RapidFire (atyp, dtyp);

                        if (Rapidfire == 0) rapidfire = 0;
                    }
                }
            }
        }
        for (slot=0; slot<dnum; slot++)     // �������������
        {
            for (i=0; i<dobjs; i++) {
                rapidfire = 1;
                unit = &dunits[i];
                if (unit->slot_id == slot) {
                    // �������.
                    while (rapidfire) {
                        idx = MyRand (0, aobjs-1);
                        apower = UnitShoot (unit, d[slot].weap, &aunits[idx], &absorbed[0], &dm, &dk );
                        shoots[1]++;
                        spower[1] += apower;

                        // ��������� ID � ������� ������, ����� ���� ��������.
                        atyp = unit->obj_type;      
                        if ( atyp < 200 ) atyp += 102;
                        else atyp += 201;
                        dtyp = aunits[idx].obj_type;
                        if ( dtyp < 200 ) dtyp += 102;
                        else dtyp += 201;
                        rapidfire = RapidFire (atyp, dtyp);

                        if (Rapidfire == 0) rapidfire = 0;
                    }
                }
            }
        }

        // ������� �����?
        fastdraw = CheckFastDraw (aunits, aobjs, dunits, dobjs);

        // ��������� ���������� ������� � �������.
        aobjs -= WipeExploded (&aunits, aobjs);
        dobjs -= WipeExploded (&dunits, dobjs);

        // Round.
        ptr += sprintf ( ptr, "i:%i;a:8:", rounds );
        ptr += sprintf ( ptr, "{s:6:\"ashoot\";d:%s;", longnumber(shoots[0]) );
        ptr += sprintf ( ptr, "s:6:\"apower\";d:%s;", longnumber(spower[0]) ); 
        ptr += sprintf ( ptr, "s:7:\"dabsorb\";d:%s;", longnumber(absorbed[1]) );
        ptr += sprintf ( ptr, "s:6:\"dshoot\";d:%s;", longnumber(shoots[1]) );
        ptr += sprintf ( ptr, "s:6:\"dpower\";d:%s;", longnumber(spower[1]) );
        ptr += sprintf ( ptr, "s:7:\"aabsorb\";d:%s;", longnumber(absorbed[0]) );
        ptr += sprintf ( ptr, "s:9:\"attackers\";a:%i:{", anum );
        for (slot=0; slot<anum; slot++) {
            ptr = GenSlot (ptr, aunits, slot, aobjs, a, d, 1, 0);
        }
        ptr += sprintf ( ptr, "}" );
        ptr += sprintf ( ptr, "s:9:\"defenders\";a:%i:{", dnum );
        for (slot=0; slot<dnum; slot++) {
            ptr = GenSlot (ptr, dunits, slot, dobjs, a, d, 0, 0);
        }
        ptr += sprintf ( ptr, "}" );
        ptr += sprintf ( ptr, "}" );

        if (fastdraw) { rounds ++; break; }
    }

    *round_patch = '0' + (rounds);
    
    // ���������� ���.
    if (aobjs > 0 && dobjs == 0){ // ��������� �������
        res = "awon";
    }
    else if (dobjs > 0 && aobjs == 0) { // ��������� ��������
        res = "dwon";
    }
    else    // �����
    {
        res = "draw";
    }

    ptr += sprintf (ptr, "}s:6:\"result\";s:4:\"%s\";", res);
    ptr += sprintf (ptr, "s:2:\"dm\";d:%s;", longnumber (dm));
    ptr += sprintf (ptr, "s:2:\"dk\";d:%s;}", longnumber (dk));
    
    free (aunits);
    free (dunits);
    return 1;
}

// ==========================================================================================
// ������������� ������� ������ - �������� ������ � ������������ �� �� ��������.

typedef struct SimParam {
    char    name[32];
    char    string[64];
    unsigned long value;
} SimParam;
static SimParam *simargv;
static long simargc = 0;

// ������������� ������ ���� %EF%F0%E8%E2%E5%F2 � �������� ������.
static void hexize (char *string)
{
    int hexnum;
    char *temp, c, *oldstring = string;
    long length = (long)strlen (string), p = 0, digit = 0;
    temp = (char *)malloc (length + 1);
    if (temp == NULL) return;
    while (length--) {
        c = *string++;
        if (c == 0) break;
        if (c == '%') { 
            digit = 1;
        }
        else {
            if (digit == 1) {
                if (c <= '9') hexnum = (c - '0') << 4;
                else hexnum = (10 +(c - 'A')) << 4;
                digit = 2;
            }
            else if (digit == 2) {
                if (c <= '9') hexnum |= (c - '0');
                else hexnum |= 10 + (c - 'A');
                temp[p++] = (unsigned char)hexnum;
                digit = 0;
            }
            else temp[p++] = c;
        }
    }
    temp[p++] = 0;
    memcpy (oldstring, temp, p);
    free (temp);
}

static void AddSimParam (char *name, char *string)
{
    long i;

    // ���������, ���� ����� �������� ��� ����������, ������ �������� ��� ��������.
    for (i=0; i<simargc; i++) {
        if (!strcmp (name, simargv[i].name)) {
            strncpy (simargv[i].string, string, sizeof(simargv[i].string));
            simargv[i].value = strtoul (simargv[i].string, NULL, 10);
            return;
        }
    }

    // �������� ����� ��� ����� �������� � �������� ��������.
    hexize (string);
    simargv = (SimParam *)realloc (simargv, (simargc + 1) * sizeof (SimParam) );
    strncpy (simargv[simargc].name, name, sizeof (simargv[simargc].name) );
    strncpy (simargv[simargc].string, string, sizeof (simargv[simargc].string) );
    simargv[simargc].value = strtoul (simargv[simargc].string, NULL, 10);
    simargc ++;
}

static void PrintParams (void)
{
    long i;
    SimParam *p;
    for (i=0; i<simargc; i++) {
        p = &simargv[i];
        printf ( "%i: %s = %s (%i)<br>\n", i, p->name, p->string, p->value );
    }
    printf ("<hr/>");
}

// ��������� ���������.
static void ParseQueryString (char *str)
{
    int collectname = 1;
    char namebuffer[100], stringbuffer[100], c;
    long length, namelen = 0, stringlen = 0;
    memset (namebuffer, 0, sizeof(namebuffer));
    memset (stringbuffer, 0, sizeof(stringbuffer));
    if (str == NULL) return;
    length = (long)strlen (str);
    while (length--) {
        c = *str++;
        if ( c == '=' ) {
            collectname = 0;
        }
        else if (c == '&') { // �������� ��������.
            collectname = 1;
            if (namelen >0 && stringlen > 0) {
                AddSimParam (namebuffer, stringbuffer);
            }
            memset (namebuffer, 0, sizeof(namebuffer));
            memset (stringbuffer, 0, sizeof(stringbuffer));
            namelen = stringlen = 0;
        }
        else {
            if (collectname) {
                if (namelen < 31) namebuffer[namelen++] = c;
            }
            else {
                if (stringlen < 63) stringbuffer[stringlen++] = c;
            }
        }
    }
    // �������� ��������� ��������.
    if (namelen > 0 && stringlen > 0) AddSimParam (namebuffer, stringbuffer);
}

static SimParam *ParamLookup (char *name)
{
    SimParam *p = NULL;
    long i;
    for (i=0; i<simargc; i++) {
        if (!strcmp (simargv[i].name, name)) return &simargv[i];
    }
    return p;
}

static int GetSimParamI (char *name, int def)
{
    SimParam *p = ParamLookup (name);
    if (p == NULL) return def;
    else return p->value;
}

static char *GetSimParamS (char *name, char *def)
{
    SimParam *p = ParamLookup (name);
    if (p == NULL) return def;
    else return p->string;
}

/*

������ ������� ������
������� ������ �������� �������� ��������� ����� � ��������� �������. ��� �������� ������� � ��, �������� ������������ � ������� "���������� = ��������".

Rapidfire = 1
FID = 30
DID = 0
Attackers = N
Defenders = M
AttackerN = (<NAME> ID G S P WEAP SHLD ARMR MT BT LF HF CR LINK COLON REC SPY BOMB SS DEST DS BC)
DefenderM = (<NAME> ID G S P WEAP SHLD ARMR MT BT LF HF CR LINK COLON REC SPY BOMB SS DEST DS BC RT LL HL GS IC PL SDOM LDOM)

*/

void StartBattle (char *text, int battle_id)
{
    char filename[1024];
    Slot *a, *d;
    int rf, fid, did, i, res;
    int anum = 0, dnum = 0;
    char *ptr, line[3000], buf[64], *lp, *tmp;

    ptr = strstr (text, "Rapidfire");       // ����������
    if ( ptr ) {
        ptr = strstr ( ptr, "=" ) + 1;
        rf = atoi (ptr);
    }
    else rf = 1;

    ptr = strstr (text, "FID");             // ���� � �������
    if ( ptr ) {
        ptr = strstr ( ptr, "=" ) + 1;
        fid = atoi (ptr);
    }
    else fid = 30;

    ptr = strstr (text, "DID");             // ������� � �������
    if ( ptr ) {
        ptr = strstr ( ptr, "=" ) + 1;
        did = atoi (ptr);
    }
    else did = 0;

    ptr = strstr (text, "Attackers");        // ���������� ���������
    if ( ptr ) {
        ptr = strstr ( ptr, "=" ) + 1;
        anum = atoi (ptr);
    }
    else anum = 0;
    ptr = strstr (text, "Defenders");        // ���������� �������������
    if ( ptr ) {
        ptr = strstr ( ptr, "=" ) + 1;
        dnum = atoi (ptr);
    }
    else dnum = 0;

    if ( anum == 0 || dnum == 0) return;

    a = (Slot *)malloc ( anum * sizeof (Slot) );    // �������� ������ ��� �����.
    memset ( a, 0, anum * sizeof (Slot) );
    d = (Slot *)malloc ( dnum * sizeof (Slot) );
    memset ( d, 0, dnum * sizeof (Slot) );

    // ���������.
    for (i=0; i<anum; i++)
    {
        sprintf ( buf, "Attacker%i", i );
        ptr = strstr (text, buf);
        if ( ptr ) {
            lp = line;
            ptr = strstr ( ptr, "=" ) + 1;
            while ( *ptr != '(' ) ptr++;
            ptr++;
            while ( *ptr != ')' ) *lp++ = *ptr++;
            *lp++ = 0;
        }

        // �������� ���
        lp = line;
        tmp = a[i].name;
        while ( *lp == '<' ) lp++;              // ����� ������ �����
        while ( *lp != '>' ) *tmp++ = *lp++;    // �������� ������� �� >
        *tmp++ = 0;
        lp++;
        while ( *lp <= ' ' ) lp++;              // ���������� �������
        
        // (<NAME> ID G S P WEAP SHLD ARMR MT BT LF HF CR LINK COLON REC SPY BOMB SS DEST DS BC)
        sscanf ( lp, "%i " "%i %i %i " "%i %i %i " "%i %i %i %i %i %i %i %i %i %i %i %i %i %i", 
                       &a[i].id, 
                       &a[i].g, &a[i].s, &a[i].p,
                       &a[i].weap, &a[i].shld, &a[i].armor,
                       &a[i].fleet[0], // MT
                       &a[i].fleet[1], // BT
                       &a[i].fleet[2], // LF
                       &a[i].fleet[3], // HF
                       &a[i].fleet[4], // CR
                       &a[i].fleet[5], // LINK
                       &a[i].fleet[6], // COLON
                       &a[i].fleet[7], // REC
                       &a[i].fleet[8], // SPY
                       &a[i].fleet[9], // BOMB
                       &a[i].fleet[10], // SS
                       &a[i].fleet[11], // DEST
                       &a[i].fleet[12], // DS
                       &a[i].fleet[13] ); // BC
    }

    // �������������.
    for (i=0; i<dnum; i++)
    {
        sprintf ( buf, "Defender%i", i );
        ptr = strstr (text, buf);
        if ( ptr ) {
            lp = line;
            ptr = strstr ( ptr, "=" ) + 1;
            while ( *ptr != '(' ) ptr++;
            ptr++;
            while ( *ptr != ')' ) *lp++ = *ptr++;
            *lp++ = 0;
        }

        // �������� ���
        lp = line;
        tmp = d[i].name;
        while ( *lp == '<' ) lp++;              // ����� ������ �����
        while ( *lp != '>' ) *tmp++ = *lp++;    // �������� ������� �� >
        *tmp++ = 0;
        lp++;
        while ( *lp <= ' ' ) lp++;              // ���������� �������

        // (<NAME> ID G S P WEAP SHLD ARMR MT BT LF HF CR LINK COLON REC SPY BOMB SS DEST DS BC RT LL HL GS IC PL SDOM LDOM)
        sscanf ( lp, "%i " "%i %i %i " "%i %i %i " "%i %i %i %i %i %i %i %i %i %i %i %i %i %i %i %i %i %i %i %i %i %i", 
                       &d[i].id, 
                       &d[i].g, &d[i].s, &d[i].p,
                       &d[i].weap, &d[i].shld, &d[i].armor,
                       &d[i].fleet[0], // MT
                       &d[i].fleet[1], // BT
                       &d[i].fleet[2], // LF
                       &d[i].fleet[3], // HF
                       &d[i].fleet[4], // CR
                       &d[i].fleet[5], // LINK
                       &d[i].fleet[6], // COLON
                       &d[i].fleet[7], // REC
                       &d[i].fleet[8], // SPY
                       &d[i].fleet[9], // BOMB
                       &d[i].fleet[10], // SS
                       &d[i].fleet[11], // DEST
                       &d[i].fleet[12], // DS
                       &d[i].fleet[13], // BC
                       &d[i].def[0], // RT
                       &d[i].def[1], // LL
                       &d[i].def[2], // HL
                       &d[i].def[3], // GS
                       &d[i].def[4], // IC
                       &d[i].def[5], // PL
                       &d[i].def[6], // SDOM
                       &d[i].def[7] // LDOM
                ); 
    }

    // ��������� ������� ������.
    SetDebrisOptions ( did, fid );
    SetRapidfire ( rf );

    // **** ������ ����� ****
    res = DoBattle ( a, anum, d, dnum );

    // �������� ����������.
    if ( res > 0 )
    {
        sprintf ( filename, "battleresult/battle_%i.txt", battle_id );
        FileSave ( filename, ResultBuffer, strlen (ResultBuffer) );
    }
}

void main(int argc, char **argv)
{
    char filename[1024];
    char *battle_data;

    if ( argc < 2 ) return;

    ParseQueryString ( argv[1] );
    //PrintParams ();

    // ��������� �������� ���� � ������� �������� ������.
    {
        int battle_id = GetSimParamI("battle_id", 0);
        
        if ( battle_id == 0 ) return;

        sprintf ( filename, "battledata/battle_%i.txt", battle_id );
        battle_data = FileLoad ( filename, NULL, "rt" );

        // ��������� �������� ������ � �������� ������ � ������ �����.
        MySrand ((unsigned long)time(NULL));
        StartBattle ( battle_data, battle_id );
    }
}