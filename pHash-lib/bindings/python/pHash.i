/*

    pHash, the open source perceptual hash library
    Copyright (C) 2008-2009 Aetilius, Inc.
    All rights reserved.

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.

    Evan Klinger - eklinger@phash.org
    David Starkweather - dstarkweather@phash.org
    
    swig interface by Loic Jaquemet - loic.jaquemet@gmail.com

*/
/* 
install swig python-dev CImg-dev & others
see swig autorun automake ... http://realmike.org/python/swig_linux.htm
*/

%include "std_string.i"
%include "exception.i" 
%include "typemaps.i"
%include "cpointer.i"
%include "carrays.i"
%include "cmalloc.i"

%exception {
	try {
		$function
/*
	} catch(RangeError) {
		SWIG_exception(SWIG_ValueError, "Range Error");
	} catch(DivisionByZero) {
		SWIG_exception(SWIG_DivisionByZero, "Division by zero");
	} catch(OutOfMemory) {
		SWIG_exception(SWIG_MemoryError, "Out of memory");
	*/
	} catch(...) {
		SWIG_exception(SWIG_RuntimeError,"Unknown exception");
	}
}




/* pHash.h n'est pas un header propre pour les lib externes ...
  donc on fait pHashLib.h 
*/


%ignore ph_dct;
%ignore ph_dct_matrix;
%ignore _ph_save_mvptree;
%ignore _ph_add_mvptree;
%ignore _ph_query_mvptree;
%ignore ph_getKeyFramesFromVideo;


%module pHash
%{
#include "pHash.h"

%}


/*

implicit array lenght, pour eviter le passager de int nbElements

%typemap(python,ignore) int n(int *ptr_n){
   ptr_n=&$target;
}

%typemap(python,in) double *a{
   int i,size;
   *ptr_n=size=PyList_Size($source);
   $target=(double *)malloc(sizeof(double)*size);
   for(i=0;i<size;i++){
      $target[i]=PyFloat_AsDouble(PyList_GetItem($source,i));
   }
}

%typemap(python,freearg) double *a{
   free($source);
}

%inline %{
#include <stdio.h>
void f(double* a, int n)
{
  int i;
  for(i=0;i<n;i++)
    a[i] = (double)i/(double)n;
}
%}

*/



/*
We  declare INPUT and OUTPUT parameters.
Output parameters are not longer args, but part of the return value tuple/sequence. 
*/


int ph_radon_projections(const CImg<uint8_t> &INPUT,int N,Projections &OUTPUT);
int ph_feature_vector(const Projections &INPUT,Features &OUTPUT);
int ph_dct(const Features &INPUT, Digest &OUTPUT);
int ph_crosscorr(const Digest &INPUT,const Digest &INPUT,double &INPUT, double threshold = 0.90);
int _ph_image_digest(const CImg<uint8_t> &INPUT,double sigma, double gamma,Digest &OUTPUT,int N=180);
int ph_image_digest(const char *file, double sigma, double gamma, Digest &OUTPUT,int N=180);
int ph_compare_images(const char *file1, const char *file2,double &OUTPUT, double sigma = 3.5, double gamma=1.0, int N=180,double threshold=0.90);
int ph_dct_imagehash(const char* file,ulong64 &OUTPUT);
int ph_sizeof_dp(DP *INPUT,MVPFile *INPUT);
double ph_dct_videohash_dist(ulong64 *INPUT, int N1, ulong64 *INPUT, int N2, int threshold=21);
double ph_hammingdistance2(uint8_t *INPUT, int lenA, uint8_t *INPUT, int lenB);
float hammingdistance(DP *INPUT, DP *INPUT);
MVPRetCode ph_query_mvptree(MVPFile *INPUT, DP *INPUT, int knearest, float radius,
		float threshold,   DP **OUTPUT, int &OUTPUT);
MVPRetCode ph_save_mvptree(MVPFile *INPUT, DP **INPUT, int nbpoints);
MVPRetCode ph_add_mvptree(MVPFile *INPUT, DP **INPUT, int nbpoints, int &OUTPUT);
off_t ph_save_datapoint(DP *INPUT, MVPFile *INPUT);




/*
Thoses functions returns a list of struct.
Swig gives us a pointer on the first struct, we need to use pointer function after that...
cf %array_functions(type,name)

with an OUTPUT arg, it's a tuple :

Python :
>>> ( Proxy Class, nbvalue) = pHash.ph_texthash(filename)

I can't find a way to make that into a swig list of some sort ...

typemap(out0) type*... impacts the pointer constructor... no good.

/*
%typemap(out) TxtMatch * {
    PyObject *list = PyList_New(*arg5);
    int i =0;
    printf("arg5 value is %d\n",*arg5);
    for(i=0; i< *arg5; i++ ) {
      //PyList_Append(list,$1[i]);
		  PyList_SetItem(list,$1[i]);
		}
    $result=list;
}
*/

/*
The easiest way should be to write a full Class aroud thoses...
*/

%array_functions(TxtHashPoint,TxtHashPointArray)
%array_functions(TxtMatch,TxtMatchArray)

//%array_class(TxtHashPoint,TxtHashPointArray);
//%array_class(TxtMatch,TxtMatchArray);

TxtHashPoint* ph_texthash(const char *filename, int *OUTPUT);
TxtMatch* ph_compare_text_hashes(TxtHashPoint *INPUT, int N1, TxtHashPoint *INPUT, int N2, int *OUTPUT);

/* todo */
ulong64* ph_dct_videohash(const char *filename, int &OUTPUT);
DP** ph_read_imagehashes(const char *dirname,int capacity, int &OUTPUT);
uint8_t* ph_mh_imagehash(const char *filename, int &OUTPUT, float alpha=2.0f, float lvl = 1.0f);
char** ph_readfilenames(const char *dirname,int &OUTPUT);
DP* ph_read_datapoint(MVPFile *INPUT);





/* -------------------------- std */

/* Create some functions for working with "double *" */
%pointer_functions(double, doublep);

/* Create some functions for working with "int *" */
%pointer_functions(int, intp);
%pointer_functions(uint64_t, uint64_tp);
%pointer_functions(ulong64, ulong64p);

/* functions pour ph_digest & Digest */
%pointer_functions(uint8_t, uint8_tp);
%array_functions(uint8_t,uint8_tArray);
%free(uint8_t);




/* http://thread.gmane.org/gmane.comp.programming.swig/12746/focus=12747 */
namespace cimg_library {}

/* %ignore mvptag; */




/*
%define vector_typemap(T)
%typemap(python,out) vector<T *> *, vector<T *> &{ 
 $target = PyList_New(0);
 if($source){
    for(vector<T *>::iterator i=$source->begin();
              i!=$source->end();i++){
       PyObject *o=SWIG_NewPointerObj((void *)(*i), SWIGTYPE_p_##T);
       PyList_Append($target,o);
       Py_XDECREF(o);
    }                       
    //delete $source; //depends on your code
 }
}
%enddef

vector_typemap(TxtMatch);


*/


%apply long { off_t };   


/* probleme sur primary-expression */  
%include "pHash.h" 











