!MNH_LIC Copyright 1994-2024 CNRS, Meteo-France and Universite Paul Sabatier
!MNH_LIC This is part of the Meso-NH software governed by the CeCILL-C licence
!MNH_LIC version 1. See LICENSE, CeCILL-C_V1-en.txt and CeCILL-C_V1-fr.txt
!MNH_LIC for details. version 1.
!-----------------------------------------------------------------
!     ##################
      MODULE MODI_SHUMAN
!     ##################
!
IMPLICIT NONE
INTERFACE DXM
 FUNCTION DXM(PA)  RESULT(PDXM)
 IMPLICIT NONE
 REAL, DIMENSION(:,:,:), INTENT(IN)                :: PA     ! variable at mass localization
 REAL, DIMENSION(SIZE(PA,1),SIZE(PA,2),SIZE(PA,3)) :: PDXM   ! result at flux side
 END FUNCTION DXM
 !
 FUNCTION DXM_2D(PA)  RESULT(PDXM)
 IMPLICIT NONE
 REAL, DIMENSION(:,:), INTENT(IN)                :: PA     ! variable at mass localization
 REAL, DIMENSION(SIZE(PA,1),SIZE(PA,2)) :: PDXM   ! result at flux side
 END FUNCTION DXM_2D
END INTERFACE
!
INTERFACE DYM
 FUNCTION DYM(PA)  RESULT(PDYM)
 IMPLICIT NONE
 REAL, DIMENSION(:,:,:), INTENT(IN)                :: PA     ! variable at mass localization
 REAL, DIMENSION(SIZE(PA,1),SIZE(PA,2),SIZE(PA,3)) :: PDYM   ! result at flux side
 END FUNCTION DYM
!
 FUNCTION DYM_2D(PA)  RESULT(PDYM)
 IMPLICIT NONE
 REAL, DIMENSION(:,:), INTENT(IN)                :: PA     ! variable at mass localization
 REAL, DIMENSION(SIZE(PA,1),SIZE(PA,2)) :: PDYM   ! result at flux side
 END FUNCTION DYM_2D
END INTERFACE
!
INTERFACE MXM
 FUNCTION MXM(PA)  RESULT(PMXM)
 IMPLICIT NONE
 REAL, DIMENSION(:,:,:), INTENT(IN)                :: PA     ! variable at mass localization
 REAL, DIMENSION(SIZE(PA,1),SIZE(PA,2),SIZE(PA,3)) :: PMXM   ! result at flux localization 
 END FUNCTION MXM
 !
 FUNCTION MXM_2D(PA)  RESULT(PMXM)
 IMPLICIT NONE
 REAL, DIMENSION(:,:), INTENT(IN)                :: PA     ! variable at mass localization
 REAL, DIMENSION(SIZE(PA,1),SIZE(PA,2)) :: PMXM   ! result at flux localization 
 END FUNCTION MXM_2D
END INTERFACE
!
INTERFACE MYM
 FUNCTION MYM(PA)  RESULT(PMYM)
 IMPLICIT NONE
 REAL, DIMENSION(:,:,:), INTENT(IN)                :: PA     ! variable at mass localization
 REAL, DIMENSION(SIZE(PA,1),SIZE(PA,2),SIZE(PA,3)) :: PMYM   ! result at flux localization 
 END  FUNCTION MYM
 !
 FUNCTION MYM_2D(PA)  RESULT(PMYM)
 IMPLICIT NONE
 REAL, DIMENSION(:,:), INTENT(IN)                :: PA     ! variable at mass localization
 REAL, DIMENSION(SIZE(PA,1),SIZE(PA,2)) :: PMYM   ! result at flux localization 
 END  FUNCTION MYM_2D
END INTERFACE
!
INTERFACE MXF
 FUNCTION MXF(PA)  RESULT(PMXF)
 IMPLICIT NONE
 REAL, DIMENSION(:,:,:), INTENT(IN)                :: PA     ! variable at flux side
 REAL, DIMENSION(SIZE(PA,1),SIZE(PA,2),SIZE(PA,3)) :: PMXF   ! result at mass localization 
 END FUNCTION MXF
!
 FUNCTION MXF_2D(PA)  RESULT(PMXF)
 IMPLICIT NONE
 REAL, DIMENSION(:,:), INTENT(IN)                :: PA     ! variable at flux side
 REAL, DIMENSION(SIZE(PA,1),SIZE(PA,2)) :: PMXF   ! result at mass localization 
 END FUNCTION MXF_2D
!
END INTERFACE
!
INTERFACE MYF
 FUNCTION MYF_2D(PA)  RESULT(PMYF)
 IMPLICIT NONE
 REAL, DIMENSION(:,:), INTENT(IN)                :: PA     ! variable at flux side
 REAL, DIMENSION(SIZE(PA,1),SIZE(PA,2)) :: PMYF   ! result at mass localization 
 END FUNCTION MYF_2D
 ! 
 FUNCTION MYF(PA)  RESULT(PMYF)
 IMPLICIT NONE
 REAL, DIMENSION(:,:,:), INTENT(IN)                :: PA     ! variable at flux side
 REAL, DIMENSION(SIZE(PA,1),SIZE(PA,2),SIZE(PA,3)) :: PMYF   ! result at mass localization 
 END FUNCTION MYF
END INTERFACE
!
INTERFACE
!
FUNCTION DXF(PA)  RESULT(PDXF)
IMPLICIT NONE
REAL, DIMENSION(:,:,:), INTENT(IN)                :: PA     ! variable at flux side
REAL, DIMENSION(SIZE(PA,1),SIZE(PA,2),SIZE(PA,3)) :: PDXF   ! result at mass localization
END FUNCTION DXF
!
FUNCTION DYF(PA)  RESULT(PDYF)
IMPLICIT NONE
REAL, DIMENSION(:,:,:), INTENT(IN)                :: PA     ! variable at flux side
REAL, DIMENSION(SIZE(PA,1),SIZE(PA,2),SIZE(PA,3)) :: PDYF   ! result at mass localization 
END FUNCTION DYF
!
FUNCTION DZF(PA)  RESULT(PDZF)
IMPLICIT NONE
REAL, DIMENSION(:,:,:), INTENT(IN)                :: PA     ! variable at flux side
REAL, DIMENSION(SIZE(PA,1),SIZE(PA,2),SIZE(PA,3)) :: PDZF   ! result at mass localization
END FUNCTION DZF
!
FUNCTION DZM(PA)  RESULT(PDZM)
IMPLICIT NONE
REAL, DIMENSION(:,:,:), INTENT(IN)                :: PA     ! variable at mass localization
REAL, DIMENSION(SIZE(PA,1),SIZE(PA,2),SIZE(PA,3)) :: PDZM   ! result at flux side
END FUNCTION DZM
!
FUNCTION MZF(PA)  RESULT(PMZF)
IMPLICIT NONE
REAL, DIMENSION(:,:,:), INTENT(IN)                :: PA     ! variable at flux side
REAL, DIMENSION(SIZE(PA,1),SIZE(PA,2),SIZE(PA,3)) :: PMZF   ! result at mass localization
END FUNCTION MZF
!
FUNCTION MZM(PA)  RESULT(PMZM)
IMPLICIT NONE
REAL, DIMENSION(:,:,:), INTENT(IN)                :: PA     ! variable at mass localization
REAL, DIMENSION(SIZE(PA,1),SIZE(PA,2),SIZE(PA,3)) :: PMZM   ! result at flux localization 
END FUNCTION MZM
!
END INTERFACE
!
END MODULE MODI_SHUMAN
!
!
!     ###############################
      FUNCTION MXF(PA)  RESULT(PMXF)
!     ###############################
!
!!****  *MXF* -  Shuman operator : mean operator in x direction for a 
!!                                 variable at a flux side
!!
!!    PURPOSE
!!    -------
!       The purpose of this function  is to compute a mean 
!     along the x direction (I index) for a field PA localized at a x-flux
!     point (u point). The result is localized at a mass point.
!
!!**  METHOD
!!    ------ 
!!        The result PMXF(i,:,:) is defined by 0.5*(PA(i,:,:)+PA(i+1,:,:))
!!        At i=size(PA,1), PMXF(i,:,:) are replaced by the values of PMXF,
!!    which are the right values in the x-cyclic case
!!    
!!
!!    EXTERNAL
!!    --------
!!      NONE
!!
!!    IMPLICIT ARGUMENTS
!!    ------------------
!!      Module MODD_PARAMETERS: declaration of parameter variables
!!        JPHEXT: define the number of marginal points out of the 
!!        physical domain along the horizontal directions.
!!
!!    REFERENCE
!!    ---------
!!      Book2 of documentation of Meso-NH (SHUMAN operators)
!!      Technical specifications Report of The Meso-NH (chapters 3)  
!!
!!
!!    AUTHOR
!!    ------
!!    V. Ducrocq       * Meteo France *
!!
!!    MODIFICATIONS
!!    -------------
!!      Original    04/07/94 
!!      Modification to include the periodic case 13/10/94 J.Stein 
!!                   optimisation                 20/08/00 J. Escobar
!!      correction of in halo/pseudo-cyclic calculation for JPHEXT<> 1   
!!      J.Escobar : 15/09/2015 : WENO5 & JPHEXT <> 1 
!-------------------------------------------------------------------------------
!
!*       0.    DECLARATIONS
!              ------------
!
USE MODD_PARAMETERS
!
IMPLICIT NONE
!
!*       0.1   Declarations of argument and result
!              ------------------------------------
!
REAL, DIMENSION(:,:,:), INTENT(IN)                :: PA     ! variable at flux side
REAL, DIMENSION(SIZE(PA,1),SIZE(PA,2),SIZE(PA,3)) :: PMXF   ! result at mass localization 
!
!*       0.2   Declarations of local variables
!              -------------------------------
!
INTEGER :: JI, JJ, JK     ! Loop indices
INTEGER :: IIU, IJU, IKU  ! upper bounds of PA
!
#ifdef _OPT_LINEARIZED_LOOPS
INTEGER :: JJK
INTEGER :: JIJK,JIJKOR,JIJKEND
#endif
! 
!
!-------------------------------------------------------------------------------
!
!*       1.    DEFINITION OF MXF
!              ------------------
!
IIU = SIZE(PA,1)
IJU = SIZE(PA,2)
IKU = SIZE(PA,3)
!
#ifndef _OPT_LINEARIZED_LOOPS
DO JK = 1, IKU
  DO JJ = 1, IJU
    DO JI = 1 + 1, IIU
      PMXF(JI-1,JJ,JK) = 0.5*( PA(JI-1,JJ,JK)+PA(JI,JJ,JK) )
    ENDDO
  ENDDO
ENDDO
!
PMXF(IIU,:,:)    = PMXF(2*JPHEXT,:,:) 
#else
JIJKOR  = 1 + 1
JIJKEND = IIU*IJU*IKU
!
!CDIR NODEP
!OCL NOVREC
DO JIJK=JIJKOR , JIJKEND
  PMXF(JIJK-1,1,1) = 0.5*( PA(JIJK-1,1,1)+PA(JIJK,1,1) )
END DO
!
!CDIR NODEP
!OCL NOVREC
DO JI=1,JPHEXT
   DO JJK=1,IJU*IKU
      PMXF(IIU-JPHEXT+JI,JJK,1) = PMXF(JPHEXT+JI,JJK,1) ! for reprod JPHEXT <> 1
   END DO
END DO
#endif
!
!-------------------------------------------------------------------------------
!
END FUNCTION MXF
!
!     ###############################
      FUNCTION MXF_2D(PA)  RESULT(PMXF)
!     ###############################
!
!!****  *MXF_2D* -  Shuman operator : mean operator in x direction for a 
!!                                 variable at a flux side
!!    SAME AS MXF for a 2D Variable (selection of the level K) only in turb_hor*
!!
!-------------------------------------------------------------------------------
!
!*       0.    DECLARATIONS
!              ------------
!
USE MODD_PARAMETERS
!
IMPLICIT NONE
!
!*       0.1   Declarations of argument and result
!              ------------------------------------
!
REAL, DIMENSION(:,:), INTENT(IN)                :: PA     ! variable at flux side
REAL, DIMENSION(SIZE(PA,1),SIZE(PA,2)) :: PMXF   ! result at mass localization 
!
!*       0.2   Declarations of local variables
!              -------------------------------
!
INTEGER :: JI, JJ     ! Loop indices
INTEGER :: IIU, IJU  ! upper bounds of PA
!
#ifdef _OPT_LINEARIZED_LOOPS
INTEGER :: JIJ,JIJOR,JIJEND
#endif
! 
!
!-------------------------------------------------------------------------------
!
!*       1.    DEFINITION OF MXF
!              ------------------
!
IIU = SIZE(PA,1)
IJU = SIZE(PA,2)
!
#ifndef _OPT_LINEARIZED_LOOPS
  DO JJ = 1, IJU
    DO JI = 1 + 1, IIU
      PMXF(JI-1,JJ) = 0.5*( PA(JI-1,JJ)+PA(JI,JJ) )
    ENDDO
  ENDDO
!
PMXF(IIU,:)    = PMXF(2*JPHEXT,:) 
#else
JIJOR  = 1 + 1
JIJEND = IIU*IJU
!
!CDIR NODEP
!OCL NOVREC
DO JIJ=JIJOR , JIJEND
  PMXF(JIJ-1,1) = 0.5*( PA(JIJ-1,1)+PA(JIJ,1) )
END DO
!
!CDIR NODEP
!OCL NOVREC
DO JI=1,JPHEXT
   DO JJ=1,IJU*IU
      PMXF(IIU-JPHEXT+JI,JJ) = PMXF(JPHEXT+JI,JJ) ! for reprod JPHEXT <> 1
   END DO
END DO
#endif
!
!-------------------------------------------------------------------------------
!
END FUNCTION MXF_2D

!     ###############################
      FUNCTION MXM(PA)  RESULT(PMXM)
!     ###############################
!
!!****  *MXM* -  Shuman operator : mean operator in x direction for a 
!!                                 mass variable 
!!
!!    PURPOSE
!!    -------
!       The purpose of this function  is to compute a mean 
!     along the x direction (I index) for a field PA localized at a mass
!     point. The result is localized at a x-flux point (u point).
!
!!**  METHOD
!!    ------ 
!!        The result PMXM(i,:,:) is defined by 0.5*(PA(i,:,:)+PA(i-1,:,:))
!!    At i=1, PMXM(1,:,:) are replaced by the values of PMXM,
!!    which are the right values in the x-cyclic case. 
!!    
!!
!!    EXTERNAL
!!    --------
!!      NONE
!!
!!    IMPLICIT ARGUMENTS
!!    ------------------
!!      Module MODD_PARAMETERS: declaration of parameter variables
!!        JPHEXT: define the number of marginal points out of the 
!!        physical domain along the horizontal directions.
!!
!!    REFERENCE
!!    ---------
!!      Book2 of documentation of Meso-NH (SHUMAN operators)
!!      Technical specifications Report of The Meso-NH (chapters 3)  
!!
!!
!!    AUTHOR
!!    ------
!!    V. Ducrocq       * Meteo France *
!!
!!    MODIFICATIONS
!!    -------------
!!      Original    04/07/94
!!      Modification to include the periodic case 13/10/94 J.Stein 
!!                   optimisation                 20/08/00 J. Escobar
!!      correction of in halo/pseudo-cyclic calculation for JPHEXT<> 1 
!!      J.Escobar : 15/09/2015 : WENO5 & JPHEXT <> 1 
!-------------------------------------------------------------------------------
!
!*       0.    DECLARATIONS
!              ------------
!
USE MODD_PARAMETERS
!
IMPLICIT NONE
!
!*       0.1   Declarations of argument and result
!              ------------------------------------
!
REAL, DIMENSION(:,:,:), INTENT(IN)                :: PA     ! variable at mass localization
REAL, DIMENSION(SIZE(PA,1),SIZE(PA,2),SIZE(PA,3)) :: PMXM   ! result at flux localization 
!
!*       0.2   Declarations of local variables
!              -------------------------------
!
INTEGER :: JI, JJ, JK     ! Loop indices
INTEGER :: IIU, IJU, IKU  ! upper bounds of PA
!
#ifdef _OPT_LINEARIZED_LOOPS
INTEGER :: JJK
INTEGER :: JIJK,JIJKOR,JIJKEND
#endif
!            
!
!-------------------------------------------------------------------------------
!
!*       1.    DEFINITION OF MXM
!              ------------------
!
IIU = SIZE(PA,1)
IJU = SIZE(PA,2)
IKU = SIZE(PA,3)
!
#ifndef _OPT_LINEARIZED_LOOPS
DO JK = 1, IKU
  DO JJ = 1, IJU
    DO JI = 1 + 1, IIU
      PMXM(JI,JJ,JK) = 0.5*( PA(JI,JJ,JK)+PA(JI-1,JJ,JK) )
    ENDDO
  ENDDO
ENDDO
!
DO JK = 1, IKU
  DO JJ=1,IJU
    PMXM(1,JJ,JK)    = PMXM(IIU-2*JPHEXT+1,JJ,JK)  	!TODO: voir si ce n'est pas plutot JPHEXT+1
  ENDDO
ENDDO
#else
JIJKOR  = 1 + 1
JIJKEND = IIU*IJU*IKU
!
!CDIR NODEP
!OCL NOVREC
DO JIJK=JIJKOR , JIJKEND
   PMXM(JIJK,1,1) = 0.5*( PA(JIJK,1,1)+PA(JIJK-1,1,1) )
END DO
!
!CDIR NODEP
!OCL NOVREC
DO JI=1,JPHEXT
   DO JJK=1,IJU*IKU
      PMXM(JI,JJK,1) = PMXM(IIU-2*JPHEXT+JI,JJK,1) ! for reprod JPHEXT <> 1
   END DO
END DO
#endif
!
!-------------------------------------------------------------------------------
!
END FUNCTION MXM
!
!     ###############################
      FUNCTION MXM_2D(PA)  RESULT(PMXM)
!     ###############################
!
!!****  *MXM* -  Shuman operator : mean operator in x direction for a 
!!                                 mass variable 
!!
!!    SAME AS MXM for a 2D Variable (selection of the level K) only in turb_hor*
! 
!*       0.    DECLARATIONS
!              ------------
!
USE MODD_PARAMETERS
!
IMPLICIT NONE
!
!*       0.1   Declarations of argument and result
!              ------------------------------------
!
REAL, DIMENSION(:,:), INTENT(IN)                :: PA     ! variable at mass localization
REAL, DIMENSION(SIZE(PA,1),SIZE(PA,2)) :: PMXM   ! result at flux localization 
!
!*       0.2   Declarations of local variables
!              -------------------------------
!
INTEGER :: JI, JJ     ! Loop indices
INTEGER :: IIU, IJU  ! upper bounds of PA
!
#ifdef _OPT_LINEARIZED_LOOPS
INTEGER :: JIJ,JIJOR,JIJEND
#endif
!            
!
!-------------------------------------------------------------------------------
!
!*       1.    DEFINITION OF MXM
!              ------------------
!
IIU = SIZE(PA,1)
IJU = SIZE(PA,2)
!
#ifndef _OPT_LINEARIZED_LOOPS
  DO JJ = 1, IJU
    DO JI = 1 + 1, IIU
      PMXM(JI,JJ) = 0.5*( PA(JI,JJ)+PA(JI-1,JJ) )
    ENDDO
  ENDDO
!
  DO JJ=1,IJU
    PMXM(1,JJ)    = PMXM(IIU-2*JPHEXT+1,JJ)  	!TODO: voir si ce n'est pas plutot JPHEXT+1
  ENDDO
#else
JIJOR  = 1 + 1
JIJEND = IIU*IJU
!
!CDIR NODEP
!OCL NOVREC
DO JIJ=JIJOR , JIJEND
   PMXM(JIJ,1) = 0.5*( PA(JIJ,1)+PA(JIJ-1,1) )
END DO
!
!CDIR NODEP
!OCL NOVREC
DO JI=1,JPHEXT
   DO JJ=1,IJU*IU
      PMXM(JI,JJ) = PMXM(IIU-2*JPHEXT+JI,JJ) ! for reprod JPHEXT <> 1
   END DO
END DO
#endif
!
!-------------------------------------------------------------------------------
!
END FUNCTION MXM_2D

!     ###############################
      FUNCTION MYF(PA)  RESULT(PMYF)
!     ###############################
!
!!****  *MYF* -  Shuman operator : mean operator in y direction for a 
!!                                 variable at a flux side
!!
!!    PURPOSE
!!    -------
!       The purpose of this function  is to compute a mean 
!     along the y direction (J index) for a field PA localized at a y-flux
!     point (v point). The result is localized at a mass point.
!
!!**  METHOD
!!    ------ 
!!        The result PMYF(i,:,:) is defined by 0.5*(PA(:,j,:)+PA(:,j+1,:))
!!        At j=size(PA,2), PMYF(:,j,:) are replaced by the values of PMYF,
!!    which are the right values in the y-cyclic case
!!    
!!
!!    EXTERNAL
!!    --------
!!      NONE
!!
!!    IMPLICIT ARGUMENTS
!!    ------------------
!!      Module MODD_PARAMETERS: declaration of parameter variables
!!        JPHEXT: define the number of marginal points out of the 
!!        physical domain along the horizontal directions.
!!
!!    REFERENCE
!!    ---------
!!      Book2 of documentation of Meso-NH (SHUMAN operators)
!!      Technical specifications Report of The Meso-NH (chapters 3)  
!!
!!
!!    AUTHOR
!!    ------
!!    V. Ducrocq       * Meteo France *
!!
!!    MODIFICATIONS
!!    -------------
!!      Original    04/07/94 
!!      Modification to include the periodic case 13/10/94 J.Stein 
!!                   optimisation                 20/08/00 J. Escobar
!!      correction of in halo/pseudo-cyclic calculation for JPHEXT<> 1   
!!      J.Escobar : 15/09/2015 : WENO5 & JPHEXT <> 1  
!-------------------------------------------------------------------------------
!
!*       0.    DECLARATIONS
!              ------------
!
USE MODD_PARAMETERS
!
IMPLICIT NONE
!
!*       0.1   Declarations of argument and result
!              ------------------------------------
!
REAL, DIMENSION(:,:,:), INTENT(IN)                :: PA     ! variable at flux side
REAL, DIMENSION(SIZE(PA,1),SIZE(PA,2),SIZE(PA,3)) :: PMYF   ! result at mass localization 
!
!*       0.2   Declarations of local variables
!              -------------------------------
!
INTEGER :: JI, JJ, JK     ! Loop indices
INTEGER :: IIU, IJU, IKU  ! upper bounds of PA
!
#ifdef _OPT_LINEARIZED_LOOPS
INTEGER :: JIJK,JIJKOR,JIJKEND
#endif
!       
!
!-------------------------------------------------------------------------------
!
!*       1.    DEFINITION OF MYF
!              ------------------
!
IIU = SIZE(PA,1)
IJU = SIZE(PA,2)
IKU = SIZE(PA,3)
!
#ifndef _OPT_LINEARIZED_LOOPS
DO JK=1,IKU
  DO JJ=1,IJU-1
    DO JI=1,IIU !TODO: remplacer le 1 par JPHEXT ?
      PMYF(JI,JJ,JK) = 0.5*( PA(JI,JJ,JK)+PA(JI,JJ+1,JK) )
    END DO
  END DO
END DO
#else
JIJKOR  = 1 + IIU
JIJKEND = IIU*IJU*IKU
!
!CDIR NODEP
!OCL NOVREC
DO JIJK=JIJKOR , JIJKEND
   PMYF(JIJK-IIU,1,1) = 0.5*( PA(JIJK-IIU,1,1)+PA(JIJK,1,1) )
END DO
#endif
!
DO JJ=1,JPHEXT
   PMYF(:,IJU-JPHEXT+JJ,:) = PMYF(:,JPHEXT+JJ,:) ! for reprod JPHEXT <> 1
END DO
!
!
!-------------------------------------------------------------------------------
!
END FUNCTION MYF
!
!     ###############################
      FUNCTION MYF_2D(PA)  RESULT(PMYF)
!     ###############################
!
!!****  *MYF_2D* -  Shuman operator : mean operator in y direction for a 
!!                                 variable at a flux side
!!    SAME AS MYF for a 2D Variable (selection of the level K) only in turb_hor*
!!
!-------------------------------------------------------------------------------
!
!*       0.    DECLARATIONS
!              ------------
!
USE MODD_PARAMETERS
!
IMPLICIT NONE
!
!*       0.1   Declarations of argument and result
!              ------------------------------------
!
REAL, DIMENSION(:,:), INTENT(IN)                :: PA     ! variable at flux side
REAL, DIMENSION(SIZE(PA,1),SIZE(PA,2)) :: PMYF   ! result at mass localization 
!
!*       0.2   Declarations of local variables
!              -------------------------------
!
INTEGER :: JI, JJ     ! Loop indices
INTEGER :: IIU, IJU  ! upper bounds of PA
!
#ifdef _OPT_LINEARIZED_LOOPS
INTEGER :: JIJ,JIJOR,JIJEND
#endif
!       
!
!-------------------------------------------------------------------------------
!
!*       1.    DEFINITION OF MYF
!              ------------------
!
IIU = SIZE(PA,1)
IJU = SIZE(PA,2)
!
#ifndef _OPT_LINEARIZED_LOOPS
  DO JJ=1,IJU-1
    DO JI=1,IIU !TODO: remplacer le 1 par JPHEXT ?
      PMYF(JI,JJ) = 0.5*( PA(JI,JJ)+PA(JI,JJ+1) )
    END DO
  END DO
#else
JIJOR  = 1 + IIU
JIJEND = IIU*IJU
!
!CDIR NODEP
!OCL NOVREC
DO JIJ=JIJOR , JIJEND
   PMYF(JIJ-IIU,1) = 0.5*( PA(JIJ-IIU,1)+PA(JIJ,1) )
END DO
#endif
!
DO JJ=1,JPHEXT
   PMYF(:,IJU-JPHEXT+JJ) = PMYF(:,JPHEXT+JJ) ! for reprod JPHEXT <> 1
END DO
!
!
!-------------------------------------------------------------------------------
!
END FUNCTION MYF_2D

!     ###############################
      FUNCTION MYM(PA)  RESULT(PMYM)
!     ###############################
!
!!****  *MYM* -  Shuman operator : mean operator in y direction for a 
!!                                 mass variable 
!!
!!    PURPOSE
!!    -------
!       The purpose of this function  is to compute a mean 
!     along the y direction (J index) for a field PA localized at a mass
!     point. The result is localized at a y-flux point (v point).
!
!!**  METHOD
!!    ------ 
!!        The result PMYM(:,j,:) is defined by 0.5*(PA(:,j,:)+PA(:,j-1,:))
!!    At j=1, PMYM(:,j,:) are replaced by the values of PMYM,
!!    which are the right values in the y-cyclic case. 
!!    
!!
!!    EXTERNAL
!!    --------
!!      NONE
!!
!!    IMPLICIT ARGUMENTS
!!    ------------------
!!      Module MODD_PARAMETERS: declaration of parameter variables
!!        JPHEXT: define the number of marginal points out of the 
!!        physical domain along the horizontal directions.
!!
!!    REFERENCE
!!    ---------
!!      Book2 of documentation of Meso-NH (SHUMAN operators)
!!      Technical specifications Report of The Meso-NH (chapters 3)  
!!
!!
!!    AUTHOR
!!    ------
!!    V. Ducrocq       * Meteo France *
!!
!!    MODIFICATIONS
!!    -------------
!!      Original    04/07/94 
!!      Modification to include the periodic case 13/10/94 J.Stein 
!!                   optimisation                 20/08/00 J. Escobar
!!      correction of in halo/pseudo-cyclic calculation for JPHEXT<> 1    
!!      J.Escobar : 15/09/2015 : WENO5 & JPHEXT <> 1 
!-------------------------------------------------------------------------------
!
!*       0.    DECLARATIONS
!              ------------
!
USE MODD_PARAMETERS
!
IMPLICIT NONE
!
!*       0.1   Declarations of argument and result
!              ------------------------------------
!
REAL, DIMENSION(:,:,:), INTENT(IN)                :: PA     ! variable at mass localization
REAL, DIMENSION(SIZE(PA,1),SIZE(PA,2),SIZE(PA,3)) :: PMYM   ! result at flux localization 
!
!*       0.2   Declarations of local variables
!              -------------------------------
!
INTEGER :: JI, JJ, JK     ! Loop indices
INTEGER :: IIU, IJU, IKU  ! upper bounds of PA
!
#ifdef _OPT_LINEARIZED_LOOPS
INTEGER :: JJK
INTEGER :: JIJK,JIJKOR,JIJKEND
#endif
!   
!-------------------------------------------------------------------------------
!
!*       1.    DEFINITION OF MYM
!              ------------------
!
IIU=SIZE(PA,1)
IJU=SIZE(PA,2)
IKU=SIZE(PA,3)
!
#ifndef _OPT_LINEARIZED_LOOPS
DO JK=1,IKU
  DO JJ=2,IJU !TODO: remplacer le 1+1 par 1+JPHEXT ?
    DO JI=1,IIU
      PMYM(JI,JJ,JK) = 0.5*( PA(JI,JJ,JK)+PA(JI,JJ-1,JK) )
    END DO
  END DO
END DO
#else
JIJKOR  = 1 + IIU
JIJKEND = IIU*IJU*IKU
!CDIR NODEP
!OCL NOVREC
DO JIJK=JIJKOR , JIJKEND
   PMYM(JIJK,1,1) = 0.5*( PA(JIJK,1,1)+PA(JIJK-IIU,1,1) )
END DO
#endif
!
DO JJ=1,JPHEXT
   PMYM(:,JJ,:)  = PMYM(:,IJU-2*JPHEXT+JJ,:) ! for reprod JPHEXT <> 1
END DO
!
!-------------------------------------------------------------------------------
!
END FUNCTION MYM
!
!     ###############################
      FUNCTION MYM_2D(PA)  RESULT(PMYM)
!     ###############################
!
!!****  *MYM* -  Shuman operator : mean operator in y direction for a 
!!                                 mass variable 
!!
!!    SAME AS MYM for a 2D Variable (selection of the level K) only in turb_hor*
!-------------------------------------------------------------------------------
!
!*       0.    DECLARATIONS
!              ------------
!
USE MODD_PARAMETERS
!
IMPLICIT NONE
!
!*       0.1   Declarations of argument and result
!              ------------------------------------
!
REAL, DIMENSION(:,:), INTENT(IN)                :: PA     ! variable at mass localization
REAL, DIMENSION(SIZE(PA,1),SIZE(PA,2)) :: PMYM   ! result at flux localization 
!
!*       0.2   Declarations of local variables
!              -------------------------------
!
INTEGER :: JI, JJ     ! Loop indices
INTEGER :: IIU, IJU  ! upper bounds of PA
!
#ifdef _OPT_LINEARIZED_LOOPS
INTEGER :: JIJ,JIJOR,JIJEND
#endif
!   
!-------------------------------------------------------------------------------
!
!*       1.    DEFINITION OF MYM
!              ------------------
!
IIU=SIZE(PA,1)
IJU=SIZE(PA,2)
!
#ifndef _OPT_LINEARIZED_LOOPS
  DO JJ=2,IJU !TODO: remplacer le 1+1 par 1+JPHEXT ?
    DO JI=1,IIU
      PMYM(JI,JJ) = 0.5*( PA(JI,JJ)+PA(JI,JJ-1) )
    END DO
  END DO
#else
JIJOR  = 1 + IIU
JIJEND = IIU*IJU
!CDIR NODEP
!OCL NOVREC
DO JIJ=JIJOR , JIJEND
   PMYM(JIJ,1) = 0.5*( PA(JIJ,1)+PA(JIJ-IIU,1) )
END DO
#endif
!
DO JJ=1,JPHEXT
   PMYM(:,JJ)  = PMYM(:,IJU-2*JPHEXT+JJ) ! for reprod JPHEXT <> 1
END DO
!
!-------------------------------------------------------------------------------
!
END FUNCTION MYM_2D
!
!     ###############################
      FUNCTION MZF(PA)  RESULT(PMZF)
!     ###############################
!
!!****  *MZF* -  Shuman operator : mean operator in z direction for a 
!!                                 variable at a flux side
!!
!!    PURPOSE
!!    -------
!       The purpose of this function  is to compute a mean 
!     along the z direction (K index) for a field PA localized at a z-flux
!     point (w point). The result is localized at a mass point.
!
!!**  METHOD
!!    ------ 
!!        The result PMZF(:,:,k) is defined by 0.5*(PA(:,:,k)+PA(:,:,k+1))
!!        At k=size(PA,3), PMZF(:,:,k) is defined by -999.
!!    
!!
!!    EXTERNAL
!!    --------
!!      NONE
!!
!!    IMPLICIT ARGUMENTS
!!    ------------------
!!      NONE
!!
!!    REFERENCE
!!    ---------
!!      Book2 of documentation of Meso-NH (SHUMAN operators)
!!      Technical specifications Report of The Meso-NH (chapters 3)  
!!
!!
!!    AUTHOR
!!    ------
!!    V. Ducrocq       * Meteo France *
!!
!!    MODIFICATIONS
!!    -------------
!!      Original    04/07/94 
!!                   optimisation                 20/08/00 J. Escobar
!-------------------------------------------------------------------------------
!
!*       0.    DECLARATIONS
!              ------------
!
IMPLICIT NONE
!
!*       0.1   Declarations of argument and result
!              ------------------------------------
!
REAL, DIMENSION(:,:,:), INTENT(IN)                :: PA     ! variable at flux side
REAL, DIMENSION(SIZE(PA,1),SIZE(PA,2),SIZE(PA,3)) :: PMZF   ! result at mass localization
!
!*       0.2   Declarations of local variables
!              -------------------------------
!
INTEGER :: JI, JJ, JK     ! Loop indices
INTEGER :: IIU, IJU, IKU  ! upper bounds of PA
!
#ifdef _OPT_LINEARIZED_LOOPS
INTEGER :: JIJ
INTEGER :: JIJK,JIJKOR,JIJKEND
#endif
!   
!
!-------------------------------------------------------------------------------
!
!*       1.    DEFINITION OF MZF
!              ------------------
!
IIU = SIZE(PA,1)
IJU = SIZE(PA,2)
IKU = SIZE(PA,3)
!
#ifndef _OPT_LINEARIZED_LOOPS
PMZF(:,:,1:IKU-1) = 0.5*( PA(:,:,1:IKU-1)+PA(:,:,2:) )
!
PMZF(:,:,IKU) = -999.
#else
JIJKOR  = 1 + IIU*IJU
JIJKEND = IIU*IJU*IKU
!
!CDIR NODEP
!OCL NOVREC
DO JIJK=JIJKOR , JIJKEND
   PMZF(JIJK-IIU*IJU,1,1) = 0.5*( PA(JIJK-IIU*IJU,1,1)+PA(JIJK,1,1) )
END DO
!
!CDIR NODEP
!OCL NOVREC
DO JIJ=1,IIU*IJU
   PMZF(JIJ,1,IKU)    = PMZF(JIJ,1,IKU-1) !-999.
END DO
#endif
!
!-------------------------------------------------------------------------------
!
END FUNCTION MZF
!
!     ###############################
      FUNCTION MZM(PA)  RESULT(PMZM)
!     ###############################
!
!!****  *MZM* -  Shuman operator : mean operator in z direction for a 
!!                                 mass variable 
!!
!!    PURPOSE
!!    -------
!       The purpose of this function  is to compute a mean
!     along the z direction (K index) for a field PA localized at a mass
!     point. The result is localized at a z-flux point (w point).
!
!!**  METHOD
!!    ------ 
!!        The result PMZM(:,:,k) is defined by 0.5*(PA(:,:,k)+PA(:,:,k-1))
!!        At k=1, PMZM(:,:,1) is defined by -999.
!!    
!!
!!    EXTERNAL
!!    --------
!!      NONE
!!
!!    IMPLICIT ARGUMENTS
!!    ------------------
!!      NONE
!!
!!    REFERENCE
!!    ---------
!!      Book2 of documentation of Meso-NH (SHUMAN operators)
!!      Technical specifications Report of The Meso-NH (chapters 3)  
!!
!!
!!    AUTHOR
!!    ------
!!    V. Ducrocq       * Meteo France *
!!
!!    MODIFICATIONS
!!    -------------
!!      Original    04/07/94 
!!                   optimisation                 20/08/00 J. Escobar
!-------------------------------------------------------------------------------
!
!*       0.    DECLARATIONS
!              ------------
!
IMPLICIT NONE
!
!*       0.1   Declarations of argument and result
!              ------------------------------------
!
REAL, DIMENSION(:,:,:), INTENT(IN)                :: PA     ! variable at mass localization
REAL, DIMENSION(SIZE(PA,1),SIZE(PA,2),SIZE(PA,3)) :: PMZM   ! result at flux localization 
!
!*       0.2   Declarations of local variables
!              -------------------------------
!
INTEGER :: JI, JJ, JK     ! Loop indices
INTEGER :: IIU, IJU, IKU  ! upper bounds of PA
!
#ifdef _OPT_LINEARIZED_LOOPS
INTEGER :: JIJ
INTEGER :: JIJK,JIJKOR,JIJKEND
#endif
!  
!
!-------------------------------------------------------------------------------
!
!*       1.    DEFINITION OF MZM
!              ------------------
!
#ifndef _OPT_LINEARIZED_LOOPS
IKU = SIZE(PA,3)
!
DO JK=2,IKU !TODO: remplacer le 2 par JPHEXT+1 ?
  PMZM(:,:,JK) = 0.5* ( PA(:,:,JK) + PA(:,:,JK-1) )
END DO
!
PMZM(:,:,1)    = -999.
#else
IIU = SIZE(PA,1)
IJU = SIZE(PA,2)
IKU = SIZE(PA,3)
!
JIJKOR  = 1 + IIU*IJU
JIJKEND = IIU*IJU*IKU
!
!CDIR NODEP
!OCL NOVREC
DO JIJK=JIJKOR , JIJKEND
   PMZM(JIJK,1,1) = 0.5*( PA(JIJK,1,1)+PA(JIJK-IIU*IJU,1,1) )
END DO
!
!CDIR NODEP
!OCL NOVREC
DO JIJ=1,IIU*IJU
   PMZM(JIJ,1,1)    = -999.
END DO
!
#endif
!
!-------------------------------------------------------------------------------
!
END FUNCTION MZM
!
!     ###############################
      FUNCTION DXF(PA)  RESULT(PDXF)
!     ###############################
!
!!****  *DXF* -  Shuman operator : finite difference operator in x direction
!!                                  for a variable at a flux side
!!
!!    PURPOSE
!!    -------
!       The purpose of this function  is to compute a finite difference 
!     along the x direction (I index) for a field PA localized at a x-flux
!     point (u point). The result is localized at a mass point.
!
!!**  METHOD
!!    ------ 
!!        The result PDXF(i,:,:) is defined by (PA(i+1,:,:)-PA(i,:,:))
!!        At i=size(PA,1), PDXF(i,:,:) are replaced by the values of PDXF,
!!    which are the right values in the x-cyclic case
!!    
!!
!!    EXTERNAL
!!    --------
!!      NONE
!!
!!    IMPLICIT ARGUMENTS
!!    ------------------
!!      Module MODD_PARAMETERS: declaration of parameter variables
!!        JPHEXT: define the number of marginal points out of the 
!!        physical domain along the horizontal directions.
!!
!!    REFERENCE
!!    ---------
!!      Book2 of documentation of Meso-NH (SHUMAN operators)
!!      Technical specifications Report of The Meso-NH (chapters 3)  
!!
!!
!!    AUTHOR
!!    ------
!!    V. Ducrocq       * Meteo France *
!!
!!    MODIFICATIONS
!!    -------------
!!      Original    05/07/94 
!!      Modification to include the periodic case 13/10/94 J.Stein 
!!                   optimisation                 20/08/00 J. Escobar
!!      correction of in halo/pseudo-cyclic calculation for JPHEXT<> 1    
!!      J.Escobar : 15/09/2015 : WENO5 & JPHEXT <> 1 
!-------------------------------------------------------------------------------
!
!*       0.    DECLARATIONS
!              ------------
!
USE MODD_PARAMETERS
!
IMPLICIT NONE
!
!*       0.1   Declarations of argument and result
!              ------------------------------------
!
REAL, DIMENSION(:,:,:), INTENT(IN)                :: PA     ! variable at flux side
REAL, DIMENSION(SIZE(PA,1),SIZE(PA,2),SIZE(PA,3)) :: PDXF   ! result at mass localization 
!
!*       0.2   Declarations of local variables
!              -------------------------------
!
INTEGER :: JI, JJ, JK     ! Loop indices
INTEGER :: IIU, IJU, IKU  ! upper bounds of PA
!
#ifdef _OPT_LINEARIZED_LOOPS
INTEGER :: JJK
INTEGER :: JIJK,JIJKOR,JIJKEND
#endif
!    
!
!-------------------------------------------------------------------------------
!
!*       1.    DEFINITION OF DXF
!              ------------------
!
IIU = SIZE(PA,1)
IJU = SIZE(PA,2)
IKU = SIZE(PA,3)
!
#ifndef _OPT_LINEARIZED_LOOPS
DO JK=1,IKU
  DO JJ=1,IJU
    DO JI=1+1,IIU
     PDXF(JI-1,JJ,JK) = PA(JI,JJ,JK) - PA(JI-1,JJ,JK) 
    END DO
  END DO
END DO
!
DO JK=1,IKU
  DO JJ=1,IJU
    PDXF(IIU,JJ,JK)    = PDXF(2*JPHEXT,JJ,JK) 
  ENDDO
ENDDO
#else
JIJKOR  = 1 + 1
JIJKEND = IIU*IJU*IKU
!
!CDIR NODEP
!OCL NOVREC
DO JIJK=JIJKOR , JIJKEND
   PDXF(JIJK-1,1,1) = PA(JIJK,1,1) - PA(JIJK-1,1,1) 
END DO
!
!CDIR NODEP
!OCL NOVREC
DO JI=1,JPHEXT
   DO JJK=1,IJU*IKU
      PDXF(IIU-JPHEXT+JI,JJK,1) = PDXF(JPHEXT+JI,JJK,1) ! for reprod JPHEXT <> 1
   END DO
END DO
#endif
!
!-------------------------------------------------------------------------------
!
END FUNCTION DXF
!
!     ###############################
      FUNCTION DXM_2D(PA)  RESULT(PDXM)
!     ###############################
!
!!****  *DXM_2D* -  Shuman operator : finite difference operator in x direction
!!                                  for a variable in 2D at a mass localization
!!
!!    SAME AS DXM for a 2D Variable (selection of the level K) only in turb_hor*
!
USE MODD_PARAMETERS
!
IMPLICIT NONE
!
!*       0.1   Declarations of argument and result
!              ------------------------------------
!
REAL, DIMENSION(:,:), INTENT(IN)                :: PA     ! variable at mass localization
REAL, DIMENSION(SIZE(PA,1),SIZE(PA,2)) :: PDXM   ! result at flux side
!
!*       0.2   Declarations of local variables
!              -------------------------------
!
INTEGER :: JI, JJ     ! Loop indices
INTEGER :: IIU, IJU  ! upper bounds of PA
!
#ifdef _OPT_LINEARIZED_LOOPS
INTEGER :: JJ
INTEGER :: JIJ,JIJOR,JIJEND
#endif
!   
!-------------------------------------------------------------------------------
!
!*       1.    DEFINITION OF DXM
!              ------------------
!
IIU = SIZE(PA,1)
IJU = SIZE(PA,2)
!
#ifndef _OPT_LINEARIZED_LOOPS
  DO JJ=1,IJU
    DO JI=1+1,IIU !TODO: remplacer le 1 par JPHEXT ?
      PDXM(JI,JJ) = PA(JI,JJ) - PA(JI-1,JJ) 
    END DO
  END DO
!
  DO JJ=1,IJU
    PDXM(1,JJ)    = PDXM(IIU-2*JPHEXT+1,JJ)   !TODO: remplacer -2*JPHEXT+1 par -JPHEXT ?
  ENDDO
#else
JIJOR  = 1 + 1
JIJEND = IIU*IJU
!
!CDIR NODEP
!OCL NOVREC
DO JIJ=JIJOR , JIJEND
   PDXM(JIJ,1) = PA(JIJ,1) - PA(JIJ-1,1) 
END DO
!
!CDIR NODEP
!OCL NOVREC
DO JI=1,JPHEXT
   DO JJ=1,IJU
      PDXM(JI,JJ) = PDXM(IIU-2*JPHEXT+JI,JJ) ! for reprod JPHEXT <> 1
   END DO
END DO
#endif
!
!-------------------------------------------------------------------------------
!
END FUNCTION DXM_2D
:
!     ###############################
      FUNCTION DXM(PA)  RESULT(PDXM)
!     ###############################
!
!!****  *DXM* -  Shuman operator : finite difference operator in x direction
!!                                  for a variable at a mass localization
!!
!!    PURPOSE
!!    -------
!       The purpose of this function  is to compute a finite difference 
!     along the x direction (I index) for a field PA localized at a mass
!     point. The result is localized at a x-flux point (u point).
!
!!**  METHOD
!!    ------ 
!!        The result PDXM(i,:,:) is defined by (PA(i,:,:)-PA(i-1,:,:))
!!    At i=1, PDXM(1,:,:) are replaced by the values of PDXM,
!!    which are the right values in the x-cyclic case. 
!!    
!!
!!    EXTERNAL
!!    --------
!!      NONE
!!
!!    IMPLICIT ARGUMENTS
!!    ------------------
!!      Module MODD_PARAMETERS: declaration of parameter variables
!!        JPHEXT: define the number of marginal points out of the 
!!        physical domain along the horizontal directions.
!!
!!    REFERENCE
!!    ---------
!!      Book2 of documentation of Meso-NH (SHUMAN operators)
!!      Technical specifications Report of The Meso-NH (chapters 3)  
!!
!!
!!    AUTHOR
!!    ------
!!    V. Ducrocq       * Meteo France *
!!
!!    MODIFICATIONS
!!    -------------
!!      Original    05/07/94 
!!      Modification to include the periodic case 13/10/94 J.Stein 
!!                   optimisation                 20/08/00 J. Escobar
!-------------------------------------------------------------------------------
!
!*       0.    DECLARATIONS
!              ------------
!
USE MODD_PARAMETERS
!
IMPLICIT NONE
!
!*       0.1   Declarations of argument and result
!              ------------------------------------
!
REAL, DIMENSION(:,:,:), INTENT(IN)                :: PA     ! variable at mass localization
REAL, DIMENSION(SIZE(PA,1),SIZE(PA,2),SIZE(PA,3)) :: PDXM   ! result at flux side
!
!*       0.2   Declarations of local variables
!              -------------------------------
!
INTEGER :: JI, JJ, JK     ! Loop indices
INTEGER :: IIU, IJU, IKU  ! upper bounds of PA
!
#ifdef _OPT_LINEARIZED_LOOPS
INTEGER :: JJK
INTEGER :: JIJK,JIJKOR,JIJKEND
#endif
!   
!-------------------------------------------------------------------------------
!
!*       1.    DEFINITION OF DXM
!              ------------------
!
IIU = SIZE(PA,1)
IJU = SIZE(PA,2)
IKU = SIZE(PA,3)
!
#ifndef _OPT_LINEARIZED_LOOPS
DO JK=1,IKU
  DO JJ=1,IJU
    DO JI=1+1,IIU !TODO: remplacer le 1 par JPHEXT ?
      PDXM(JI,JJ,JK) = PA(JI,JJ,JK) - PA(JI-1,JJ,JK) 
    END DO
  END DO
END DO
!
DO JK=1,IKU
  DO JJ=1,IJU
    PDXM(1,JJ,JK)    = PDXM(IIU-2*JPHEXT+1,JJ,JK)   !TODO: remplacer -2*JPHEXT+1 par -JPHEXT ?
  ENDDO
ENDDO
#else
JIJKOR  = 1 + 1
JIJKEND = IIU*IJU*IKU
!
!CDIR NODEP
!OCL NOVREC
DO JIJK=JIJKOR , JIJKEND
   PDXM(JIJK,1,1) = PA(JIJK,1,1) - PA(JIJK-1,1,1) 
END DO
!
!CDIR NODEP
!OCL NOVREC
DO JI=1,JPHEXT
   DO JJK=1,IJU*IKU
      PDXM(JI,JJK,1) = PDXM(IIU-2*JPHEXT+JI,JJK,1) ! for reprod JPHEXT <> 1
   END DO
END DO
#endif
!
!-------------------------------------------------------------------------------
!
END FUNCTION DXM
!
!     ###############################
      FUNCTION DYF(PA)  RESULT(PDYF)
!     ###############################
!
!!****  *DYF* -  Shuman operator : finite difference operator in y direction
!!                                  for a variable at a flux side
!!
!!    PURPOSE
!!    -------
!       The purpose of this function  is to compute a finite difference 
!     along the y direction (J index) for a field PA localized at a y-flux
!     point (v point). The result is localized at a mass point.
!
!!**  METHOD
!!    ------ 
!!        The result PDYF(:,j,:) is defined by (PA(:,j+1,:)-PA(:,j,:))
!!        At j=size(PA,2), PDYF(:,j,:) are replaced by the values of PDYM,
!!    which are the right values in the y-cyclic case
!!    
!!
!!    EXTERNAL
!!    --------
!!      NONE
!!
!!    IMPLICIT ARGUMENTS
!!    ------------------
!!      Module MODD_PARAMETERS: declaration of parameter variables
!!        JPHEXT: define the number of marginal points out of the 
!!        physical domain along the horizontal directions.
!!
!!    REFERENCE
!!    ---------
!!      Book2 of documentation of Meso-NH (SHUMAN operators)
!!      Technical specifications Report of The Meso-NH (chapters 3)  
!!
!!
!!    AUTHOR
!!    ------
!!    V. Ducrocq       * Meteo France *
!!
!!    MODIFICATIONS
!!    -------------
!!      Original    05/07/94 
!!      Modification to include the periodic case 13/10/94 J.Stein 
!!                   optimisation                 20/08/00 J. Escobar
!!      correction of in halo/pseudo-cyclic calculation for JPHEXT<> 1 
!!      J.Escobar : 15/09/2015 : WENO5 & JPHEXT <> 1 
!-------------------------------------------------------------------------------
!
!*       0.    DECLARATIONS
!              ------------
!
USE MODD_PARAMETERS
!
IMPLICIT NONE
!
!*       0.1   Declarations of argument and result
!              ------------------------------------
!
REAL, DIMENSION(:,:,:), INTENT(IN)                :: PA     ! variable at flux side
REAL, DIMENSION(SIZE(PA,1),SIZE(PA,2),SIZE(PA,3)) :: PDYF   ! result at mass localization 
!
!*       0.2   Declarations of local variables
!              -------------------------------
!
INTEGER :: JI, JJ, JK     ! Loop indices
INTEGER :: IIU, IJU, IKU  ! upper bounds of PA
!
#ifdef _OPT_LINEARIZED_LOOPS
INTEGER :: JIJK,JIJKOR,JIJKEND
#endif
!   
!-------------------------------------------------------------------------------
!
!*       1.    DEFINITION OF DYF
!              ------------------
!
IIU = SIZE(PA,1)
IJU = SIZE(PA,2)
IKU = SIZE(PA,3)
!
#ifndef _OPT_LINEARIZED_LOOPS
DO JK=1,IKU
  DO JJ=1,IJU-1 !TODO: remplacer le 1 par JPHEXT ?
    DO JI=1,IIU
      PDYF(JI,JJ,JK) = PA(JI,JJ+1,JK) - PA(JI,JJ,JK) 
    END DO
  END DO
END DO
#else
JIJKOR  = 1 + IIU
JIJKEND = IIU*IJU*IKU
!
!CDIR NODEP
!OCL NOVREC
DO JIJK=JIJKOR , JIJKEND
   PDYF(JIJK-IIU,1,1)         = PA(JIJK,1,1)  -  PA(JIJK-IIU,1,1) 
END DO
#endif
!
DO JJ=1,JPHEXT
   PDYF(:,IJU-JPHEXT+JJ,:) = PDYF(:,JPHEXT+JJ,:) ! for reprod JPHEXT <> 1
END DO
!
!-------------------------------------------------------------------------------
!
END FUNCTION DYF
!
!     ###############################
      FUNCTION DYM(PA)  RESULT(PDYM)
!     ###############################
!
!!****  *DYM* -  Shuman operator : finite difference operator in y direction
!!                                  for a variable at a mass localization
!!
!!    PURPOSE
!!    -------
!       The purpose of this function  is to compute a finite difference 
!     along the y direction (J index) for a field PA localized at a mass
!     point. The result is localized at a y-flux point (v point).
!
!!**  METHOD
!!    ------ 
!!        The result PDYM(:,j,:) is defined by (PA(:,j,:)-PA(:,j-1,:))
!!    At j=1, PDYM(:,1,:) are replaced by the values of PDYM,
!!    which are the right values in the y-cyclic case. 
!!    
!!
!!    EXTERNAL
!!    --------
!!      NONE
!!
!!    IMPLICIT ARGUMENTS
!!    ------------------
!!      Module MODD_PARAMETERS: declaration of parameter variables
!!        JPHEXT: define the number of marginal points out of the 
!!        physical domain along the horizontal directions.
!!
!!    REFERENCE
!!    ---------
!!      Book2 of documentation of Meso-NH (SHUMAN operators)
!!      Technical specifications Report of The Meso-NH (chapters 3)  
!!
!!
!!    AUTHOR
!!    ------
!!    V. Ducrocq       * Meteo France *
!!
!!    MODIFICATIONS
!!    -------------
!!      Original    05/07/94 
!!      Modification to include the periodic case 13/10/94 J.Stein 
!!                   optimisation                 20/08/00 J. Escobar
!!      correction of in halo/pseudo-cyclic calculation for JPHEXT<> 1 
!!      J.Escobar : 15/09/2015 : WENO5 & JPHEXT <> 1 
!-------------------------------------------------------------------------------
!
!*       0.    DECLARATIONS
!              ------------
!
USE MODD_PARAMETERS
!
IMPLICIT NONE
!
!*       0.1   Declarations of argument and result
!              ------------------------------------
!
REAL, DIMENSION(:,:,:), INTENT(IN)                :: PA     ! variable at mass localization
REAL, DIMENSION(SIZE(PA,1),SIZE(PA,2),SIZE(PA,3)) :: PDYM   ! result at flux side
!
!*       0.2   Declarations of local variables
!              -------------------------------
!
INTEGER :: JI, JJ, JK     ! Loop indices
INTEGER :: IIU, IJU, IKU  ! upper bounds of PA
!
#ifdef _OPT_LINEARIZED_LOOPS
INTEGER :: JIJK,JIJKOR,JIJKEND
#endif
!     
!-------------------------------------------------------------------------------
!
!*       1.    DEFINITION OF DYM
!              ------------------
!
IIU=SIZE(PA,1)
IJU=SIZE(PA,2)
IKU=SIZE(PA,3)
!
#ifndef _OPT_LINEARIZED_LOOPS
DO JK=1,IKU
  DO JJ=2,IJU !TODO: remplacer le 2 par JPHEXT+1 ?
    DO JI=1,IIU
      PDYM(JI,JJ,JK) = PA(JI,JJ,JK) - PA(JI,JJ-1,JK) 
    END DO
  END DO
END DO
!
DO JJ=1,JPHEXT
   PDYM(:,JJ,:) = PDYM(:,IJU-2*JPHEXT+JJ,:) ! for reprod JPHEXT <> 1
END DO
#else
JIJKOR  = 1 + IIU
JIJKEND = IIU*IJU*IKU
!
!CDIR NODEP
!OCL NOVREC
DO JIJK=JIJKOR , JIJKEND
   PDYM(JIJK,1,1)           = PA(JIJK,1,1)  -  PA(JIJK-IIU,1,1) 
END DO
!
DO JJ=1,JPHEXT
   PDYM(:,JJ,:) = PDYM(:,IJU-2*JPHEXT+JJ,:) ! for reprod JPHEXT <> 1
END DO
#endif
!
!
!-------------------------------------------------------------------------------
!
END FUNCTION DYM
!
!     ###############################
      FUNCTION DYM_2D(PA)  RESULT(PDYM)
!     ###############################
!
!!****  *DYM* -  Shuman operator : finite difference operator in y direction
!!                                  for a variable at a mass localization
!!
!!    SAME AS DYM for a 2D Variable (selection of the level K) only in turb_hor*
!-------------------------------------------------------------------------------
!
!*       0.    DECLARATIONS
!              ------------
!
USE MODD_PARAMETERS
!
IMPLICIT NONE
!
!*       0.1   Declarations of argument and result
!              ------------------------------------
!
REAL, DIMENSION(:,:), INTENT(IN)                :: PA     ! variable at mass localization
REAL, DIMENSION(SIZE(PA,1),SIZE(PA,2)) :: PDYM   ! result at flux side
!
!*       0.2   Declarations of local variables
!              -------------------------------
!
INTEGER :: JI, JJ     ! Loop indices
INTEGER :: IIU, IJU  ! upper bounds of PA
!
#ifdef _OPT_LINEARIZED_LOOPS
INTEGER :: JIJ,JIJOR,JIJEND
#endif
!     
!-------------------------------------------------------------------------------
!
!*       1.    DEFINITION OF DYM
!              ------------------
!
IIU=SIZE(PA,1)
IJU=SIZE(PA,2)
!
#ifndef _OPT_LINEARIZED_LOOPS
  DO JJ=2,IJU !TODO: remplacer le 2 par JPHEXT+1 ?
    DO JI=1,IIU
      PDYM(JI,JJ) = PA(JI,JJ) - PA(JI,JJ-1) 
    END DO
  END DO
!
DO JJ=1,JPHEXT
   PDYM(:,JJ) = PDYM(:,IJU-2*JPHEXT+JJ) ! for reprod JPHEXT <> 1
END DO
#else
JIJOR  = 1 + IIU
JIJEND = IIU*IJU
!
!CDIR NODEP
!OCL NOVREC
DO JIJ=JIJOR , JIJEND
   PDYM(JIJ,1)           = PA(JIJ,1)  -  PA(JIJ-IIU,1) 
END DO
!
DO JJ=1,JPHEXT
   PDYM(:,JJ) = PDYM(:,IJU-2*JPHEXT+JJ) ! for reprod JPHEXT <> 1
END DO
#endif
!
!
!-------------------------------------------------------------------------------
!
END FUNCTION DYM_2D
!
!     ###############################
      FUNCTION DZF(PA)  RESULT(PDZF)
!     ###############################
!
!!****  *DZF* -  Shuman operator : finite difference operator in z direction
!!                                  for a variable at a flux side
!!
!!    PURPOSE
!!    -------
!       The purpose of this function  is to compute a finite difference 
!     along the z direction (K index) for a field PA localized at a z-flux
!     point (w point). The result is localized at a mass point.
!
!!**  METHOD
!!    ------ 
!!        The result PDZF(:,:,k) is defined by (PA(:,:,k+1)-PA(:,:,k))
!!        At k=size(PA,3), PDZF(:,:,k) is defined by -999.
!!    
!!
!!    EXTERNAL
!!    --------
!!      NONE
!!
!!    IMPLICIT ARGUMENTS
!!    ------------------
!!      NONE
!!
!!    REFERENCE
!!    ---------
!!      Book2 of documentation of Meso-NH (SHUMAN operators)
!!      Technical specifications Report of The Meso-NH (chapters 3)  
!!
!!
!!    AUTHOR
!!    ------
!!    V. Ducrocq       * Meteo France *
!!
!!    MODIFICATIONS
!!    -------------
!!      Original    05/07/94 
!!                   optimisation                 20/08/00 J. Escobar
!-------------------------------------------------------------------------------
!
!*       0.    DECLARATIONS
!              ------------
!
IMPLICIT NONE
!
!*       0.1   Declarations of argument and result
!              ------------------------------------
!
REAL, DIMENSION(:,:,:), INTENT(IN)                :: PA     ! variable at flux side
REAL, DIMENSION(SIZE(PA,1),SIZE(PA,2),SIZE(PA,3)) :: PDZF   ! result at mass localization
!
!*       0.2   Declarations of local variables
!              -------------------------------
!
INTEGER :: JI, JJ, JK     ! Loop indices
INTEGER :: IIU, IJU, IKU  ! upper bounds of PA
!
#ifdef _OPT_LINEARIZED_LOOPS
INTEGER :: JIJ
INTEGER :: JIJK,JIJKOR,JIJKEND
#endif
!
!-------------------------------------------------------------------------------
!
!*       1.    DEFINITION OF DZF
!              ------------------
!
IIU = SIZE(PA,1)
IJU = SIZE(PA,2)
IKU = SIZE(PA,3)
!
#ifndef _OPT_LINEARIZED_LOOPS
DO JK=1,IKU-1 !TODO: remplacer le 1 par JPHEXT ?
  DO JJ=1,IJU
    DO JI=1,IIU
      PDZF(JI,JJ,JK) = PA(JI,JJ,JK+1)-PA(JI,JJ,JK)
    END DO
  END DO
END DO
!
PDZF(:,:,IKU) = -999.
#else
JIJKOR  = 1 + IIU*IJU
JIJKEND = IIU*IJU*IKU
!
!CDIR NODEP
!OCL NOVREC
DO JIJK=JIJKOR , JIJKEND
   PDZF(JIJK-IIU*IJU,1,1)     = PA(JIJK,1,1)-PA(JIJK-IIU*IJU,1,1)
END DO
!
!CDIR NODEP
!OCL NOVREC
DO JIJ=1,IIU*IJU
   PDZF(JIJ,1,IKU)    = -999.
END DO
#endif
!
!-------------------------------------------------------------------------------
!
END FUNCTION DZF
!
!     ###############################
      FUNCTION DZM(PA)  RESULT(PDZM)
!     ###############################
!
!!****  *DZM* -  Shuman operator : finite difference operator in z direction
!!                                  for a variable at a mass localization
!!
!!    PURPOSE
!!    -------
!       The purpose of this function  is to compute a finite difference 
!     along the z direction (K index) for a field PA localized at a mass
!     point. The result is localized at a z-flux point (w point).
!
!!**  METHOD
!!    ------ 
!!        The result PDZM(:,j,:) is defined by (PA(:,:,k)-PA(:,:,k-1))
!!        At k=1, PDZM(:,:,k) is defined by -999.
!!    
!!
!!    EXTERNAL
!!    --------
!!      NONE
!!
!!    IMPLICIT ARGUMENTS
!!    ------------------
!!      NONE
!!
!!    REFERENCE
!!    ---------
!!      Book2 of documentation of Meso-NH (SHUMAN operators)
!!      Technical specifications Report of The Meso-NH (chapters 3)  
!!
!!
!!    AUTHOR
!!    ------
!!    V. Ducrocq       * Meteo France *
!!
!!    MODIFICATIONS
!!    -------------
!!      Original    05/07/94 
!!                   optimisation                 20/08/00 J. Escobar
!-------------------------------------------------------------------------------
!
!*       0.    DECLARATIONS
!              ------------
!
IMPLICIT NONE
!
!*       0.1   Declarations of argument and result
!              ------------------------------------
!
REAL, DIMENSION(:,:,:), INTENT(IN)                :: PA     ! variable at mass localization
REAL, DIMENSION(SIZE(PA,1),SIZE(PA,2),SIZE(PA,3)) :: PDZM   ! result at flux side
!
!*       0.2   Declarations of local variables
!              -------------------------------
!
INTEGER :: JI, JJ, JK     ! Loop indices
INTEGER :: IIU, IJU, IKU  ! upper bounds of PA
!
#ifdef _OPT_LINEARIZED_LOOPS
INTEGER :: JIJ
INTEGER :: JIJK,JIJKOR,JIJKEND
#endif
!  
!-------------------------------------------------------------------------------
!
!*       1.    DEFINITION OF DZM
!              ------------------
!
IIU = SIZE(PA,1)
IJU = SIZE(PA,2)
IKU = SIZE(PA,3)
!
#ifndef _OPT_LINEARIZED_LOOPS
DO JK=2,IKU !TODO: remplacer le 1+1 par 1+JPHEXT ?
  DO JJ=1,IJU
    DO JI=1,IIU
      PDZM(JI,JJ,JK) = PA(JI,JJ,JK) - PA(JI,JJ,JK-1) 
    END DO
  END DO
END DO
!
PDZM(:,:,1) = -999.
#else
JIJKOR  = 1 + IIU*IJU
JIJKEND = IIU*IJU*IKU
!
!CDIR NODEP
!OCL NOVREC
DO JIJK=JIJKOR , JIJKEND
  PDZM(JIJK,1,1) = PA(JIJK,1,1)-PA(JIJK-IIU*IJU,1,1)
END DO
!
!CDIR NODEP
!OCL NOVREC
DO JIJ=1,IIU*IJU
  PDZM(JIJ,1,1)    = -999.
END DO
#endif
!
!-------------------------------------------------------------------------------
!
END FUNCTION DZM
