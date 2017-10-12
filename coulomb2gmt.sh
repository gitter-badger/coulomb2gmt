#!/bin/bash

#plot Coulomb Stress change to GMT maps
# //////////////////////////////////////////////////////////////////////////////
# ==============================================================================
#   
#    |===========================================|
#    |**     DIONYSOS SATELLITE OBSERVATORY    **|
#    |**        HIGHER GEODESY LABORATORY      **|
#    |** National Tecnical University of Athens**|
#    |===========================================|
#   
#    filename              : coulomb2gmt.sh
#                            NAME=coulomb2gmt
#    version               : v-1.0
#                            VERSION=v1.0
#                            RELEASE=beta
#    licence               : MIT
#    created               : SEP-2015
#    usage                 :
#    exit code(s)          : 0 -> success
#                          : 1 -> error
#    discription           : 
#    uses                  : 
#    notes                 :
#    detailed update list  : LAST_UPDATE=OCT-2017
#    contact               : Demitris Anastasiou (dganastasiou@gmail.com)
#    ----------------------------------------------------------------------
# ==============================================================================
# //////////////////////////////////////////////////////////////////////////////
# HELP FUNCTION
function help {
  echo "/******************************************************************************/"
  echo " Program Name : coulomb2gmt.sh"
  echo " Version : v-1.0-beta*"
  echo " Purpose : Plot Coulomb Stress change results"
  echo " Usage   : coulomb2gmt.sh  <inputfile> <input data> | options | "
  echo " Switches: "
  echo "/*** GENERAL OPTIONS **********************************************************/"
  echo "           -r [:=region] set different region minlon maxlon minlat maxlat prjscale"
  echo "           -topo [:=topography] plot topography using dem file if exist "
  echo "           -o [:= output] name of output files"
#   echo "           -l [:=labels] plot labels"
#   echo "           -leg [:=legend] insert legends"
  echo "           -cmt [:=Plot central moment tensors] insert file "
  echo "           -faults [:= faults] plot fault database catalogue"
  echo "           -mt [:= map title] title map default none use quotes"
  echo "           -h [:= help] help menu"
  echo "           -debug [:=DEBUG] enable debug option"
  echo "           -logogmt [:=gmt logo] Plot gmt logo and time stamp"
  echo "           -logocus [:=custom logo] Plot custom logo of your organization"
  echo ""
  echo "/*** PLOT FAULT PARAMETERS ****************************************************/"
  echo "           -fproj [:=Fault projection] "
  echo "           -fsurf [:=Fault surface] "
  echo "           -fdep [:=Fault calculation depth] "
  echo ""
  echo "/*** PLOT STRESS CHANGE OUTPUTS ***********************************************/"
  echo "           -cstress [:=Coulomb Stress] "
  echo "           -sstress [:=Shear Stress] "
  echo "           -nstress [:=Normal strain] "
  echo ""
  echo "/*** PLOT COMPONENTS OF STRAIN FIELD ******************************************/"
  echo "           -strexx [:= Exx component] "
  echo "           -streyy [:= Eyy component] "
  echo "           -strezz [:= Ezz component] "
  echo "           -streyz [:= Eyz component] "
  echo "           -strexz [:= Exz component] "
  echo "           -strexy [:= Exy component] "
  echo "           -strdil [:= Dilatation strain] "
#   echo "           -fcross [:=plot cross section projections] "
  echo ""
  echo "/*** PLOT OKADA85 *************************************************************/"
  echo "           -dgpsho : observed GPS horizontal displacements"
  echo "           -dgpshm : modeled horizontal displacements on gps site"
  echo "           -dgpsvo : observed GPS vertical displacements"
  echo "           -dgpsvm : modeled vertical displacements on gps sites"
  echo ""
  echo "/*** OUTPUT FORMATS ***********************************************************/"
  echo "            -outjpg : Adjust and convert to JPEG"
  echo "            -outpng : Adjust and convert to PNG (transparent where nothing is plotted)"
  echo "            -outeps : Adjust and convert to EPS"
  echo "            -outpdf : Adjust and convert to PDF"
  echo ""
  echo " Exit Status:    1 -> help message or error"
  echo " Exit Status: >= 0 -> sucesseful exit"
  echo ""
  echo "/******************************************************************************/"
  exit 1
}
# //////////////////////////////////////////////////////////////////////////////
# Debug function
function DEBUG()
{
 [ "$_DEBUG" == "on" ] &&  $@
}

# //////////////////////////////////////////////////////////////////////////////
# GMT parameters
#gmtset MAP_FRAME_TYPE fancy
gmt gmtset PS_PAGE_ORIENTATION portrait
gmt gmtset FONT_ANNOT_PRIMARY 8 FONT_LABEL 8 MAP_FRAME_WIDTH 0.10c FONT_TITLE 15p
gmt gmtset PS_MEDIA 19cx22c

# //////////////////////////////////////////////////////////////////////////////
# Pre-defined parameters for bash script switches
TOPOGRAPHY=0
# LABELS=0
OUTFILES=0
# LEGEND=0
FAULTS=0
LOGOGMT=0
LOGOCUS=0

RANGE=0
CSTRESS=0
SSTRESS=0
NSTRESS=0

STREXX=0
STREYY=0
STREZZ=0
STREYZ=0
STREXZ=0
STREXY=0
STRDIL=0

TEROBS=0
TEROBS_EXCL=0
PSCLEG=0

FPROJ=0
FSURF=0
FDEP=0
FCROSS=0
CMT=0

DGPSHO=0
DGPSHM=0
DGPSVO=0
DGPSVM=0

STRAIN=0
STRSC=50

OUTJPG=0
OUTPNG=0
OUTEPS=0
OUTPDF=0


# //////////////////////////////////////////////////////////////////////////////
#check default param file 
if [ ! -f "default-param" ]
then
  echo "default-param file does not exist"
  exit 1
else
  source default-param
  echo "Default parameters file: default-param"
fi

# //////////////////////////////////////////////////////////////////////////////
# GET COMMAND LINE ARGUMENTS
if [ "$#" == "0" ]
then
  help
elif [ "$#" == "1" ]
then
  if [ "$1" == "-h" ]
  then
    help
  else
    echo "***** not enough input arguments ******"
    echo " use -h to present help documentation"
    exit 1
  fi
elif [ -f ${pth2inpdir}/${1}.inp ];
then
  inputfile=${1}.inp
  pth2inpfile=${pth2inpdir}/${1}.inp
  inputdata=${2}
  echo "input file exist"
  echo "input coulomb file:" $inputfile " input data files code:" $inputdata
  while [ $# -gt 2 ]
  do
    case "$3" in
    -debug)
	_DEBUG="on"
# 	set -x
	PS4='L ${LINENO}: '
	shift
	;;
    -r)
	RANGE=1
	minlon=${4}
	maxlon=${5}
	minlat=${6}
	maxlat=${7}
	prjscale=${8}
	shift
	shift
	shift
	shift
	shift
	shift
	;;
    -topo)
	TOPOGRAPHY=1
	shift
	;;
    -o)
	OUTFILES=1
	outfile=${4}.ps
	shift
	shift
	;;
    -logogmt)
	LOGOGMT=1
	shift
	;;
    -logocus)
	LOGOCUS=1
	shift
	;;
    -cmt)
	echo
	if [ -f ${4} ];
	then
	  CMT=1
	  inpcmt=${4}
	  DEBUG echo "cmt file is: $inpcmt"
	  shift
	  shift
	else
	  echo "CMT file does not exist!CMT wil not plot"
	  shift
	fi
	;;
   -faults)
	FAULTS=1
	shift
	;;	

    -cstress)
	CSTRESS=1
	shift
	;;
    -sstress)
	SSTRESS=1
	shift
	;;
    -nstress)
	NSTRESS=1
	shift
	;;
    -strexx)
	STREXX=1
	shift
	;;
    -streyy)
	STREYY=1
	shift
	;;
    -strezz)
	STREZZ=1
	shift
	;;
    -streyz)
	STREYZ=1
	shift
	;;
    -strexz)
	STREXZ=1
	shift
	;;
    -strexy)
	STREXY=1
	shift
	;;
    -strdil)
	STRDIL=1
	shift
	;;
		-terobs)
			TEROBS=1
			terobs_file=$4
			TEROBS_STRSC=$5
			TEROBS_EXCL=$6
			shift
			shift
			shift
			shift
			;;
		-pscleg)
			PSCLEG=$4
			shift
			shift
			;;
    -fproj)
	FPROJ=1
	shift
	;;
    -fsurf)
	FSURF=1
	shift
	;;
    -fdep)
	FDEP=1
	shift
	;;
		-fcross)
			FCROSS=1
			shift
			;;
    -dgpsho)
	DGPSHO=1
	shift
	;;
    -dgpshm)
	DGPSHM=1
	shift
	;;
    -dgpsvo)
	DGPSVO=1
	shift
	;;
    -dgpsvm)
	DGPSVM=1
	shift
	;;
		-str)
			pth2inptf=../../GeoToolbox/output
			pth2work=${pth2inptf}/${4}
			pth2comp=${pth2inptf}/${4}.comp
			pth2ext=${pth2inptf}/${4}.ext
			pth2strpar=${pth2inptf}/${4}par.str
			STRAIN=1
			shift
			shift
			;;
		-strsc)
			STRSC=$4
			shift
			shift
			;;
		-dsc)
			dscale=${4}
			shift
			shift
			;;

		-l)
			LABELS=1
			shift
			;;
		-leg)
			LEGEND=1
			shift
			;;
    -outjpg)
	OUTJPG=1
	shift
	;;
    -outpng)
	OUTPNG=1
	shift
	;;
    -outeps)
	OUTEPS=1
	shift
	;;
    -outpdf)
	OUTPDF=1
	shift
	;;
	-h)
	help
	;;
    esac
  done
else
    echo " ************* File does not exist! use corret input file *********"
    help
fi

# //////////////////////////////////////////////////////////////////////////////
# Output file name definition
if [ "$OUTFILES" -eq 0 ]
then
  outfile=${inputdata}.ps
fi

# //////////////////////////////////////////////////////////////////////////////
# Paths to all input files
pth2fprojfile=${pth2datdir}/${inputdata}-gmt_fault_map_proj.dat
pth2fsurffile=${pth2datdir}/${inputdata}-gmt_fault_surface.dat
pth2fdepfile=${pth2datdir}/${inputdata}-gmt_fault_calc_dep.dat

pth2coutfile=${pth2datdir}/${inputdata}-coulomb_out.dat
pth2dcfffile=${pth2coudir}/${inputdata}-dcff.cou
pth2strnfile=${pth2coudir}/${inputdata}_Strain.cou

pth2gpsdfile=${pth2gpsdir}/${inputdata}.disp
# //////////////////////////////////////////////////////////////////////////////
# Check if all input file exist

### check fault map projection file
if [ ! -f "${pth2fprojfile}" ]
then
  echo "fault map projection file: "${pth2fprojfile}" does not exist"
  FPROJ=0
fi

### check fault surface file
if [ ! -f "${pth2fsurffile}" ]
then
  echo "fault surfece file: "${pth2fsurffile}" does not exist"
  FSURF=0
fi

### check fault surface file
if [ ! -f "${pth2fdepfile}" ]
then
  echo "fault surfece file: "${pth2fdepfile}" does not exist"
  FDEP=0
fi


### check dems
if [ "$TOPOGRAPHY" -eq 1 ]
then
  if [ ! -f $inputTopoB ]
  then
    echo "grd file for topography toes not exist, var turn to coastline"
    TOPOGRAPHY=0
  fi
fi

### check NOA FAULT catalogue
if [ "$FAULTS" -eq 1 ]
then
  if [ ! -f $pth2faults ]
  then
    echo "NOA Faults database does not exist"
    echo "please download it and then use this switch"
    FAULTS=0
  fi
fi

### check cmt file
if [ "$CMT" -eq 1 ]
then
  if [ ! -f $inpcmt ]
  then
    echo " CMT file does not exist, moment tensors will not plot"
    CMT=0
  fi
fi

### set logogmt position
if [ "$LOGOGMT" -eq 0 ]
then
  logogmt_pos=""
else
  DEBUG echo "[DEBUG] logo gmt position set: $logogmt_pos" >&2
fi

### check LOGO file
if [ ! -f "$pth2logo" ]
then
	echo "Logo file does not exist"
	LOGO=0
fi

# pth2gpsfile=${inputdata}.disp




if [ "$RANGE" -eq 0 ]
then
  minlon=$(grep "min. lon" ${pth2inpfile} | awk '{print $6}')
  maxlon=$(grep "max. lon" ${pth2inpfile} | awk '{print $6}')
  minlat=$(grep "min. lat" ${pth2inpfile} | awk '{print $6}')
  maxlat=$(grep "max. lat" ${pth2inpfile} | awk '{print $6}')
  prjscale=1500000 ##DEF 1000000
fi

sclat=$(echo print $minlat + 0.10 | python)
sclon=$(echo print $maxlon - 0.22 | python)
scale=-Lf${sclon}/${sclat}/36:24/20+l+jr
range=-R$minlon/$maxlon/$minlat/$maxlat
proj=-Jm$minlon/$minlat/1:$prjscale

DEBUG echo "[DEBUG] scale set: $scale" >&2
DEBUG echo "[DEBUG] range set: $range" >&2
DEBUG echo "[DEBUG] projection set: $proj" >&2

# //////////////////////////////////////////////////////////////////////////////
# Define to plot coastlines or topography

if [ "$CSTRESS" -eq 0 ] || [ "$SSTRESS" -eq 0 ] || [ "$NSTRESS" -eq 0 ] || [ "$DILSTRAIN" -eq 0 ]
then
  ################## Plot coastlines only ######################
  gmt pscoast $range $proj  -Df -W0.25p,black -G240  $logogmt_pos -K  -Y4.5c > $outfile 
  gmt psbasemap -R -J -O -K -B$frame:."Coulomb outputs plot": --FONT_ANNOT_PRIMARY=10p $scale --FONT_LABEL=10p >> $outfile
  
  #  PLOT NOA CATALOGUE FAULTS Ganas et.al, 2013
  if [ "$FAULTS" -eq 1 ]
  then
    echo "...plot fault database catalogue..."
    gmt	psxy $pth2faults -R -J -O -K  -W.5,204/102/0  >> $outfile
  fi
fi

if [ "$TOPOGRAPHY" -eq 1 ]
then
  # ####################### TOPOGRAPHY ###########################
  # bathymetry
  gmt makecpt -Cgebco.cpt -T-7000/0/50 -Z > $bathcpt
  gmt grdimage $inputTopoB $range $proj -C$bathcpt -K > $outfile
  gmt pscoast $proj -P $range -Df -Gc -K -O >> $outfile
  # land
  gmt makecpt -Cgray.cpt -T-6000/1800/50 -Z > $landcpt
  gmt grdimage $inputTopoL $range $proj -C$landcpt  -K -O >> $outfile
  gmt pscoast -R -J -O -K -Q >> $outfile
  #------- coastline -------------------------------------------
  gmt psbasemap -R -J -O -K -B$frame:."$maptitle":  $scale >> $outfile
  gmt pscoast -J -R -Df -W0.25p,black -K  -O -U$logo_pos >> $outfile
fi

# //////////////////////////////////////////////////////////////////////////////
# PLOT COULOMB STRESS CHANGE

if [ "$CSTRESS" -eq 1 ]
then
  echo "...plot Coulomb Stress Change map... "
  ################# Plot Coulomb source AnD coastlines only ######################
  gmt xyz2grd ${inputdata}-coulomb_out.dat -Gtmpgrd $range -I0.05
  gmt makecpt -C$coulombcpt -T-1/1/0.002 -Z > tmpcpt.cpt
  gmt grdsample tmpgrd -I4s -Gtmpgrd_sample.grd
  gmt grdimage tmpgrd_sample.grd -Ctmpcpt.cpt $proj  -K -Ei -Q -Y4.5c > $outfile
  gmt pscoast $range $proj -Df -W0.5,120 -O -K >> $outfile 
  gmt psbasemap -R -J -O -K -B$frame:."Plot Coulomb Stress Change": --FONT_ANNOT_PRIMARY=10p $scale --FONT_LABEL=10p >> $outfile
  #  PLOT NOA CATALOGUE FAULTS Ganas et.al, 2013
  if [ "$FAULTS" -eq 1 ]
  then
    echo "...plot fault database catalogue..."
    gmt	psxy $pth2faults -R -J -O -K  -W.5,204/102/0  >> $outfile
  fi
  ########### Plot scale Bar ####################
  gmt psscale -D2.75i/-0.4i/4i/0.15ih -Ctmpcpt.cpt  -B0.2/:bar: -O -K >> $outfile
  rm tmpgrd tmpgrd_sample.grd tmpcpt.cpt ## clear temporary files
fi

# //////////////////////////////////////////////////////////////////////////////
# PLOT SHEAR STRESS CHANGE

if [ "$SSTRESS" -eq 1 ]
then
  echo "...plot Shear Stress Change map..."
  # MAKE INPUT FILE........
  awk '{print $1, $2}' ${pth2coutfile} > tmpcou1
  awk 'NR>3{print $5}' ${pth2dcfffile} > tmpcou2
  paste -d" " tmpcou1 tmpcou2 >tmpcouall
 
 ################# Plot Coulomb source AnD coastlines only ######################
  gmt xyz2grd tmpcouall -Gtmpgrd $range -I0.05
  gmt makecpt -C$coulombcpt -T-1/1/0.002 -Z > tmpcpt.cpt
  gmt grdsample tmpgrd -I4s -Gtmpgrd_sample.grd
  gmt grdimage tmpgrd_sample.grd -Ctmpcpt.cpt $proj  -K -Ei -Q -Y4.5c> $outfile
  gmt pscoast $range $proj -Df -W0.5,120 -O -K >> $outfile 
  gmt psbasemap -R -J -O -K -B$frame:."Plot Shear Stress Change": --FONT_ANNOT_PRIMARY=10p $scale --FONT_LABEL=10p >> $outfile
  #  PLOT NOA CATALOGUE FAULTS Ganas et.al, 2013
  if [ "$FAULTS" -eq 1 ]
  then
    echo "...plot fault database catalogue..."
    gmt	psxy $pth2faults -R -J -O -K  -W.5,204/102/0  >> $outfile
  fi
  ########### Plot scale Bar ####################
  gmt psscale -D2.75i/-0.4i/4i/0.15ih -Ctmpcpt.cpt  -B0.2/:bar: -O -K >> $outfile
  rm tmpcou1 tmpcou2 tmpcouall tmpgrd tmpgrd_sample.grd tmpcpt.cpt ## clear temporary files
fi

# //////////////////////////////////////////////////////////////////////////////
# PLOT NORMAL STRESS CHANGE

if [ "$NSTRESS" -eq 1 ]
then
  echo "...plot Normal Stress Change map..."
  # MAKE INPUT FILE........
  awk '{print $1, $2}' ${pth2coutfile} > tmpcou1
  awk 'NR>3 {print $6}' ${pth2dcfffile} > tmpcou2
  paste -d" " tmpcou1 tmpcou2 > tmpcouall
 
  ################# Plot Coulomb source AnD coastlines only ######################
  gmt xyz2grd tmpcouall -Gtmpgrd $range -I0.05
  gmt makecpt -C$coulombcpt -T-1/1/0.002 -Z > tmpcpt.cpt
  gmt grdsample tmpgrd -I4s -Gtmpgrd_sample.grd
  gmt grdimage tmpgrd_sample.grd -Ctmpcpt.cpt $proj  -K -Ei -Q -Y4.5c> $outfile
  gmt pscoast $range $proj -Df -W0.5,120 -O -K >> $outfile 
  gmt psbasemap -R -J -O -K -B$frame:."Plot Normal Stress Change": --FONT_ANNOT_PRIMARY=10p $scale --FONT_LABEL=10p >> $outfile
  #  PLOT NOA CATALOGUE FAULTS Ganas et.al, 2013
  if [ "$FAULTS" -eq 1 ]
  then
    echo "...plot fault database catalogue..."
    gmt	psxy $pth2faults -R -J -O -K  -W.5,204/102/0  >> $outfile
  fi
  ########### Plot scale Bar ####################
  gmt psscale -D2.75i/-0.4i/4i/0.15ih -Ctmpcpt.cpt  -B0.2/:bar: -O -K >> $outfile
  rm tmpcou1 tmpcou2 tmpcouall tmpgrd tmpgrd_sample.grd tmpcpt.cpt ## clear temporary files
fi


# //////////////////////////////////////////////////////////////////////////////
# PLOT STRAIN COMPONENT Exx

if [ "$STREXX" -eq 1 ]
then
  echo "...plot Strain Component Exx..."
  # MAKE INPUT FILE........
  awk '{print $1, $2}' ${pth2coutfile} > tmpstr1
  awk 'NR>3 {print $4*1000000}' ${pth2strnfile} > tmpstr2
  paste -d" " tmpstr1 tmpstr2 > tmpstrall
  
  ################# Plot Coulomb source AnD coastlines only ######################
  gmt xyz2grd tmpstrall -Gtmpgrd $range -I0.05
  gmt makecpt -C$coulombcpt -T-1/1/0.002 -Z > tmpcpt.cpt
  gmt grdsample tmpgrd -I4s -Gtmpgrd_sample.grd
  gmt grdimage tmpgrd_sample.grd -Ctmpcpt.cpt $proj  -K -Ei -Q -Y4.5c > $outfile
  gmt pscoast $range $proj -Df -W0.5,120 -O -K >> $outfile 
  gmt psbasemap -R -J -O -K -B$frame:."Plot Strain Component Exx": --FONT_ANNOT_PRIMARY=10p $scale --FONT_LABEL=10p >> $outfile
  #  PLOT NOA CATALOGUE FAULTS Ganas et.al, 2013
  if [ "$FAULTS" -eq 1 ]
  then
    echo "...plot fault database catalogue..."
    gmt	psxy $pth2faults -R -J -O -K  -W.5,204/102/0  >> $outfile
  fi
  #////////// Plot scale Bar \\\\\\\\\\\\\\\\\\\\
  gmt psscale -D2.75i/-0.4i/4i/0.15ih -Ctmpcpt.cpt  -B0.2/:bar: -O -K >> $outfile
  rm tmpstr1 tmpstr2 tmpstrall tmpgrd tmpgrd_sample.grd tmpcpt.cpt ## clear temporary files
fi

# //////////////////////////////////////////////////////////////////////////////
# PLOT STRAIN COMPONENT Eyy

if [ "$STREYY" -eq 1 ]
then
  echo "...plot Strain Component Eyy..."
  # MAKE INPUT FILE........
  awk '{print $1, $2}' ${pth2coutfile} > tmpstr1
  awk 'NR>3 {print $5*1000000}' ${pth2strnfile} > tmpstr2
  paste -d" " tmpstr1 tmpstr2 > tmpstrall
  
  ################# Plot Coulomb source AnD coastlines only ######################
  gmt xyz2grd tmpstrall -Gtmpgrd $range -I0.05
  gmt makecpt -C$coulombcpt -T-1/1/0.002 -Z > tmpcpt.cpt
  gmt grdsample tmpgrd -I4s -Gtmpgrd_sample.grd
  gmt grdimage tmpgrd_sample.grd -Ctmpcpt.cpt $proj  -K -Ei -Q -Y4.5c > $outfile
  gmt pscoast $range $proj -Df -W0.5,120 -O -K >> $outfile 
  gmt psbasemap -R -J -O -K -B$frame:."Plot Strain Component Eyy": --FONT_ANNOT_PRIMARY=10p $scale --FONT_LABEL=10p >> $outfile
  #  PLOT NOA CATALOGUE FAULTS Ganas et.al, 2013
  if [ "$FAULTS" -eq 1 ]
  then
    echo "...plot fault database catalogue..."
    gmt	psxy $pth2faults -R -J -O -K  -W.5,204/102/0  >> $outfile
  fi
  #////////// Plot scale Bar \\\\\\\\\\\\\\\\\\\\
  gmt psscale -D2.75i/-0.4i/4i/0.15ih -Ctmpcpt.cpt  -B0.2/:bar: -O -K >> $outfile
  rm tmpstr1 tmpstr2 tmpstrall tmpgrd tmpgrd_sample.grd tmpcpt.cpt ## clear temporary files
fi

# //////////////////////////////////////////////////////////////////////////////
# PLOT STRAIN COMPONENT Ezz

if [ "$STREZZ" -eq 1 ]
then
  echo "...plot Strain Component Ezz..."
  # MAKE INPUT FILE........
  awk '{print $1, $2}' ${pth2coutfile} > tmpstr1
  awk 'NR>3 {print $6*1000000}' ${pth2strnfile} > tmpstr2
  paste -d" " tmpstr1 tmpstr2 > tmpstrall
  
  ################# Plot Coulomb source AnD coastlines only ######################
  gmt xyz2grd tmpstrall -Gtmpgrd $range -I0.05
  gmt makecpt -C$coulombcpt -T-1/1/0.002 -Z > tmpcpt.cpt
  gmt grdsample tmpgrd -I4s -Gtmpgrd_sample.grd
  gmt grdimage tmpgrd_sample.grd -Ctmpcpt.cpt $proj  -K -Ei -Q -Y4.5c > $outfile
  gmt pscoast $range $proj -Df -W0.5,120 -O -K >> $outfile 
  gmt psbasemap -R -J -O -K -B$frame:."Plot Strain Component Ezz": --FONT_ANNOT_PRIMARY=10p $scale --FONT_LABEL=10p >> $outfile
  #  PLOT NOA CATALOGUE FAULTS Ganas et.al, 2013
  if [ "$FAULTS" -eq 1 ]
  then
    echo "...plot fault database catalogue..."
    gmt	psxy $pth2faults -R -J -O -K  -W.5,204/102/0  >> $outfile
  fi
  #////////// Plot scale Bar \\\\\\\\\\\\\\\\\\\\
  gmt psscale -D2.75i/-0.4i/4i/0.15ih -Ctmpcpt.cpt  -B0.2/:bar: -O -K >> $outfile
  rm tmpstr1 tmpstr2 tmpstrall tmpgrd tmpgrd_sample.grd tmpcpt.cpt ## clear temporary files
fi

# //////////////////////////////////////////////////////////////////////////////
# PLOT STRAIN COMPONENT Eyz

if [ "$STREYZ" -eq 1 ]
then
  echo "...plot Strain Component Eyz..."
  # MAKE INPUT FILE........
  awk '{print $1, $2}' ${pth2coutfile} > tmpstr1
  awk 'NR>3 {print $7*1000000}' ${pth2strnfile} > tmpstr2
  paste -d" " tmpstr1 tmpstr2 > tmpstrall
  
  ################# Plot Coulomb source AnD coastlines only ######################
  gmt xyz2grd tmpstrall -Gtmpgrd $range -I0.05
  gmt makecpt -C$coulombcpt -T-1/1/0.002 -Z > tmpcpt.cpt
  gmt grdsample tmpgrd -I4s -Gtmpgrd_sample.grd
  gmt grdimage tmpgrd_sample.grd -Ctmpcpt.cpt $proj  -K -Ei -Q -Y4.5c > $outfile
  gmt pscoast $range $proj -Df -W0.5,120 -O -K >> $outfile 
  gmt psbasemap -R -J -O -K -B$frame:."Plot Strain Component Eyz": --FONT_ANNOT_PRIMARY=10p $scale --FONT_LABEL=10p >> $outfile
  #  PLOT NOA CATALOGUE FAULTS Ganas et.al, 2013
  if [ "$FAULTS" -eq 1 ]
  then
    echo "...plot fault database catalogue..."
    gmt	psxy $pth2faults -R -J -O -K  -W.5,204/102/0  >> $outfile
  fi
  #////////// Plot scale Bar \\\\\\\\\\\\\\\\\\\\
  gmt psscale -D2.75i/-0.4i/4i/0.15ih -Ctmpcpt.cpt  -B0.2/:bar: -O -K >> $outfile
  rm tmpstr1 tmpstr2 tmpstrall tmpgrd tmpgrd_sample.grd tmpcpt.cpt ## clear temporary files
fi

# //////////////////////////////////////////////////////////////////////////////
# PLOT STRAIN COMPONENT Exz

if [ "$STREXZ" -eq 1 ]
then
  echo "...plot Strain Component Exz..."
  # MAKE INPUT FILE........
  awk '{print $1, $2}' ${pth2coutfile} > tmpstr1
  awk 'NR>3 {print $8*1000000}' ${pth2strnfile} > tmpstr2
  paste -d" " tmpstr1 tmpstr2 > tmpstrall
  
  ################# Plot Coulomb source AnD coastlines only ######################
  gmt xyz2grd tmpstrall -Gtmpgrd $range -I0.05
  gmt makecpt -C$coulombcpt -T-1/1/0.002 -Z > tmpcpt.cpt
  gmt grdsample tmpgrd -I4s -Gtmpgrd_sample.grd
  gmt grdimage tmpgrd_sample.grd -Ctmpcpt.cpt $proj  -K -Ei -Q -Y4.5c > $outfile
  gmt pscoast $range $proj -Df -W0.5,120 -O -K >> $outfile 
  gmt psbasemap -R -J -O -K -B$frame:."Plot Strain Component Exz": --FONT_ANNOT_PRIMARY=10p $scale --FONT_LABEL=10p >> $outfile
  #  PLOT NOA CATALOGUE FAULTS Ganas et.al, 2013
  if [ "$FAULTS" -eq 1 ]
  then
    echo "...plot fault database catalogue..."
    gmt	psxy $pth2faults -R -J -O -K  -W.5,204/102/0  >> $outfile
  fi
  #////////// Plot scale Bar \\\\\\\\\\\\\\\\\\\\
  gmt psscale -D2.75i/-0.4i/4i/0.15ih -Ctmpcpt.cpt  -B0.2/:bar: -O -K >> $outfile
  rm tmpstr1 tmpstr2 tmpstrall tmpgrd tmpgrd_sample.grd tmpcpt.cpt ## clear temporary files
fi

# //////////////////////////////////////////////////////////////////////////////
# PLOT STRAIN COMPONENT Exy

if [ "$STREXY" -eq 1 ]
then
  echo "...plot Strain Component Exy..."
  # MAKE INPUT FILE........
  awk '{print $1, $2}' ${pth2coutfile} > tmpstr1
  awk 'NR>3 {print $9*1000000}' ${pth2strnfile} > tmpstr2
  paste -d" " tmpstr1 tmpstr2 > tmpstrall
  
  ################# Plot Coulomb source AnD coastlines only ######################
  gmt xyz2grd tmpstrall -Gtmpgrd $range -I0.05
  gmt makecpt -C$coulombcpt -T-1/1/0.002 -Z > tmpcpt.cpt
  gmt grdsample tmpgrd -I4s -Gtmpgrd_sample.grd
  gmt grdimage tmpgrd_sample.grd -Ctmpcpt.cpt $proj  -K -Ei -Q -Y4.5c > $outfile
  gmt pscoast $range $proj -Df -W0.5,120 -O -K >> $outfile 
  gmt psbasemap -R -J -O -K -B$frame:."Plot Strain Component Exy": --FONT_ANNOT_PRIMARY=10p $scale --FONT_LABEL=10p >> $outfile
  #  PLOT NOA CATALOGUE FAULTS Ganas et.al, 2013
  if [ "$FAULTS" -eq 1 ]
  then
    echo "...plot fault database catalogue..."
    gmt	psxy $pth2faults -R -J -O -K  -W.5,204/102/0  >> $outfile
  fi
  #////////// Plot scale Bar \\\\\\\\\\\\\\\\\\\\
  gmt psscale -D2.75i/-0.4i/4i/0.15ih -Ctmpcpt.cpt  -B0.2/:bar: -O -K >> $outfile
  rm tmpstr1 tmpstr2 tmpstrall tmpgrd tmpgrd_sample.grd tmpcpt.cpt ## clear temporary files
fi

# //////////////////////////////////////////////////////////////////////////////
# PLOT DILATATION STRAIN

if [ "$STRDIL" -eq 1 ]
then
  echo "...plot Dilatation (Exx + Eyy + Ezz)..."
  # MAKE INPUT FILE........
  awk '{print $1, $2}' ${pth2coutfile} > tmpstr1
  awk 'NR>3 {print $10*1000000}' ${pth2strnfile} > tmpstr2
  paste -d" " tmpstr1 tmpstr2 > tmpstrall
  
  ################# Plot Coulomb source AnD coastlines only ######################
  gmt xyz2grd tmpstrall -Gtmpgrd $range -I0.05
  gmt makecpt -C$coulombcpt -T-1/1/0.002 -Z > tmpcpt.cpt
  gmt grdsample tmpgrd -I4s -Gtmpgrd_sample.grd
  gmt grdimage tmpgrd_sample.grd -Ctmpcpt.cpt $proj  -K -Ei -Q -Y4.5c > $outfile
  gmt pscoast $range $proj -Df -W0.5,120 -O -K >> $outfile 
  gmt psbasemap -R -J -O -K -B$frame:."Plot Dilatation (Exx + Eyy + Ezz)": --FONT_ANNOT_PRIMARY=10p $scale --FONT_LABEL=10p >> $outfile
  #  PLOT NOA CATALOGUE FAULTS Ganas et.al, 2013
  if [ "$FAULTS" -eq 1 ]
  then
    echo "...plot fault database catalogue..."
    gmt	psxy $pth2faults -R -J -O -K  -W.5,204/102/0  >> $outfile
  fi
  #////////// Plot scale Bar \\\\\\\\\\\\\\\\\\\\
  gmt psscale -D2.75i/-0.4i/4i/0.15ih -Ctmpcpt.cpt  -B0.2/:bar: -O -K >> $outfile
  rm tmpstr1 tmpstr2 tmpstrall tmpgrd tmpgrd_sample.grd tmpcpt.cpt ## clear temporary files
fi

# //////////////////////////////////////////////////////////////////////////////
# PLOT gmt_fault_map_proj.dat 

if [ "$FPROJ" -eq 1 ]
then
  gmt psxy ${pth2fprojfile} -Jm -O -R  -W1,red  -K >> $outfile
fi
if [ "$FSURF" -eq 1 ]
then
  gmt psxy ${pth2fsurffile} -Jm -O -R  -W0.4,0  -K >> $outfile
fi
if [ "$FDEP" -eq 1 ]
then
  gmt psxy ${pth2fdepfile} -Jm -O -R -W0.4,black -K >> $outfile
fi

# //////////////////////////////////////////////////////////////////////////////
# PLOT CMT of earthquakes  

if [ "$CMT" -eq 1 ]
then
  awk '{print $1,$2}' $inpcmt | gmt psxy -Jm -O -R -Sa0.3c -Gred -K>> $outfile
# gmt psmeca $inpcmt $range -Jm -Sc0.7/0 -CP0.05  -O -P -K>> $outfile
  awk '{print $1,$2,$3,$4,$5,$6,$7,$8,$9}' $inpcmt | gmt psmeca -R -Jm -Sa0.4 -CP0.05 -K -O -P >> $outfile
fi

# //////////////////////////////////////////////////////////////////////////////
# PLOT CROSS SECTIO PROJECTION

if [ "$FCROSS" -eq 1 ]
then
	psxy  ${inputdata}-cross.ll -Jm -O -R -W0.4,blue -K >> $outfile
	awk '{print $1,$2,9,0,1,"RB",$3}' ${inputdata}-cross.ll | pstext -Jm -R -Dj0.1c/0.1c -O -V -K>> $outfile
fi

# //////////////////////////////////////////////////////////////////////////////
# PLOT GPS OBSERVED AND MODELED OKADA SURF DESPLACEMENTS

scdhmlatl=$sclat
scdhmlonl=$sclon

if [ "$DGPSHM" -eq 1 ]
then
  awk -F, 'NR>2 {print $1,$2,$6,$7,0,0,0}' $pth2gpsdfile | gmt psvelo -R -Jm -Se${dhscale}/0.95/0 -W2p,blue -A10p+e -Gblue -O -K -L -V >> $outfile 

  scdhmlat=$(echo print $sclat + .05 | python)
  scdhmlon=$sclon
  DEBUG echo "[DEBUG] scdhmlat = ${scdhmlat}  , scdhmlon = ${scdhmlon}"
  scdhmlatl=$(echo print $scdhmlat + .1 | python)
  scdhmlonl=$scdhmlon
  DEBUG echo "[DEBUG] scdhmlatl = ${scdhmlatl}  , scdhmlonl = ${scdhmlonl}"

# 	echo "$scvlon $scvlat 0.02 0 0 0 0 20 mm" | gmt psvelo -R -Jm -Se${dscale}/0.95/10 -W2p,blue -A10p+e -Gblue -O -L -V -K >> $outfile
  echo "$scdhmlon $scdhmlat 0.01 0 0 0 0 10 mm" | gmt psvelo -R -Jm -Se${dhscale}/0.95/10 -W2p,blue -A10p+e -Gblue -O -L -V -K >> $outfile
  echo "$scdhmlonl $scdhmlatl  9 0 1 CT Modeled" | gmt pstext -Jm -R -Dj0.2c/0.2c -Gwhite -O -K -V>> $outfile
# psvelo -R -Jm -Se${dscale}/0.95/10 -W2p,black -A10p+e -Gblack -O -L -V -K <<EOF>> $outfile
# #20.78 37.93 0.02 0 0 0 0 20 mm
# 20.50 37.50 0.02 0 0 0 0 20mm
# EOF
        
        
fi

if [ "$DGPSHO" -eq 1 ]
then
  awk -F, 'NR>2 {print $1,$2,$3,$4,0,0,0}' $pth2gpsdfile | gmt psvelo -R -Jm -Se${dhscale}/0.95/0 -W2p,red -A10p+e -Gred -O -K -L -V >> $outfile

  scdholat=$(echo print $scdhmlatl + .05 | python)
  scdholon=$scdhmlonl
  DEBUG echo "[DEBUG] scdholat = ${scdholat}  , scdholon = ${scdholon}"
  scdholatl=$(echo print $scdholat + .1 | python)
  scdholonl=$scdholon
  DEBUG echo "[DEBUG] scvholatl = ${scvholatl}  , scvholonl = ${scvholonl}"

# 	echo "$scvlon $scvlat 0.02 0 0 0 0 20 mm" | gmt psvelo -R -Jm -Se${dscale}/0.95/10 -W2p,blue -A10p+e -Gblue -O -L -V -K >> $outfile
  echo "$scdholon $scdholat 0.01 0 0 0 0 10 mm" | gmt psvelo -R -Jm -Se${dhscale}/0.95/10 -W2p,red -A10p+e -Gred -O -L -V -K >> $outfile
  echo "$scdholonl $scdholatl  9 0 1 CT Observed" | gmt pstext -Jm -R -Dj0.2c/0.2c -Gwhite -O -K -V>> $outfile

fi

scdvmlat=$(echo print $sclat + .25 | python)
scdvmlonl=$sclon


if [ "$DGPSVM" -eq 1 ]
then
  awk -F, 'NR>2 {if ($8<0) print $1,$2,0,$8,0,0,0}'  $pth2gpsdfile | gmt psvelo -R -Jm -Se${dvscale}/0.95/0 -W2p,blue -A10p+e -Gblue -O -K -L -V >> $outfile
  awk -F, 'NR>2 {if ($8>=0) print $1,$2,0,$8,0,0,0}' $pth2gpsdfile | gmt psvelo -R -Jm -Se${dvscale}/0.95/0 -W2p,red -A10p+e -Gred -O -K -L -V >> $outfile
  
#   scdvmlat=$(echo print $sclat + .2 | python)
  scdvmlon=$(echo print $sclon - 0.04 | python)
  DEBUG echo "[DEBUG] scdvmlat = ${scdvmlat}  , scdvmlon = ${scdvmlon}"
  scdvmlatl=$scdvmlat
  scdvmlonl=$(echo print $scdvmlon - 0.06 | python)
  DEBUG echo "[DEBUG] scdvmlatl = ${scdvmlatl}  , scdvmlonl = ${scdvmlonl}"

  echo "$scdvmlon $scdvmlat 0 -0.01 0 0 0 10 mm" | gmt psvelo -R -Jm -Se${dhscale}/0.95/0 -W2p,blue -A10p+e -Gblue -O -L -V -K >> $outfile
  echo "$scdvmlon $scdvmlat 0 0.01 0 0 0 10 mm" | gmt psvelo -R -Jm -Se${dhscale}/0.95/0 -W2p,red -A10p+e -Gred -O -L -V -K >> $outfile
  echo "$scdvmlonl $scdvmlatl 9,1,black 181 CM Modeled" | gmt pstext -R -Jm -Dj0c/0c -F+f+a+j -A -O -K -V>> $outfile

fi


if [ "$DGPSVO" -eq 1 ]
then
  DEBUG echo "[DEBUG] -X.08c add in mext line"
  awk -F, 'NR>2 {if ($5<0) print $1,$2,0,$5,0,0,0}'  $pth2gpsdfile | gmt psvelo -R -Jm -Se${dvscale}/0.95/0 -W2p,0/255/0 -G0/255/0 -O -K -L -V -X.08c >> $outfile
  awk -F, 'NR>2 {if ($5>=0) print $1,$2,0,$5,0,0,0}' $pth2gpsdfile | gmt psvelo -R -Jm -Se${dvscale}/0.95/0 -W2p,255/215/0 -A10p+e -G255/215/0 -O -K -L -V >> $outfile

  scdvolat=$scdvmlat
  scdvolon=$(echo print $sclon + 0.1 | python)
  DEBUG echo "[DEBUG] scdvolat = ${scdvolat}  , scdvmlon = ${scdvolon}"
  scdvolatl=$scdvolat
  scdvolonl=$(echo print $scdvolon - 0.06 | python)
  DEBUG echo "[DEBUG] scdvolatl = ${scdvolatl}  , scdvolonl = ${scdvolonl}"

  echo "$scdvolon $scdvolat 0 -0.01 0 0 0 10 mm" | gmt psvelo -R -Jm -Se${dhscale}/0.95/0 -W2p,0/255/0 -A10p+e -G0/255/0 -O -L -V -K >> $outfile
  echo "$scdvolon $scdvolat 0 0.01 0 0 0 10 mm" | gmt psvelo -R -Jm -Se${dhscale}/0.95/0 -W2p,255/215/0 -A10p+e -G255/215/0 -O -L -V -K >> $outfile
  echo "$scdvolonl $scdvolatl 9,1,black 181 CM Observed" | gmt pstext -R -Jm -Dj0c/0c -F+f+a+j -A -O -K -V>> $outfile

fi

if [ "$DGPSVM" -eq 1 ] || [ "$DGPSVO" -eq 1 ]
then
  scdvmolat=$(echo print $sclat + .07 | python)
  DEBUG echo "[DEBUG] -X-.08 added next line"
  echo "$sclon $scdvmolat 9,1,black 0 CM \261 10 mm" | gmt pstext -R -Jm -Dj0c/0c -F+f+a+j  -O -K -V -X-.08c >> $outfile
fi

# psvelo -R -Jm -Se${dscale}/0.95/10 -W2p,black -A10p+e -Gblack -O -L -V -K <<EOF>> $outfile
# #20.78 37.93 0.02 0 0 0 0 20 mm
# 20.50 37.50 0.02 0 0 0 0 20mm
# EOF
#/////////////////PLOT LOGO DSO
if [ "$LOGOCUS" -eq 1 ]
then
  echo "...add custom logo..."
  gmt psimage $pth2logo -O $logocus_pos  -F0.4  -K >>$outfile
fi


#################--- Close eps output file ----#################################
echo "909 909" | gmt psxy -Sc.1 -Jm -O -R  -W1,red >> $outfile

#################--- Convert to other format ----###############################
if [ "$OUTJPG" -eq 1 ]
then
	#gs -sDEVICE=jpeg -dJPEGQ=100 -dNOPAUSE -dBATCH -dSAFER -r300 -sOutputFile=$out_jpg $outfile
	gmt psconvert $outfile -A0.2c -Tj	
fi
if [ "$OUTPNG" -eq 1 ]
then
	gmt psconvert $outfile -A0.2c -TG	
fi
if [ "$OUTEPS" -eq 1 ]
then
	gmt psconvert $outfile -A0.2c -Te	
fi
if [ "$OUTPDF" -eq 1 ]
then
	gmt psconvert $outfile -A0.2c -Tf	
fi
################--- Convert to gif format ----##################################
# ps2raster -E$dpi -Tt $map.ps
# convert -delay 180 -loop 0 *.tif IonMap$date.gif

echo "Finished. Exit status: $?"