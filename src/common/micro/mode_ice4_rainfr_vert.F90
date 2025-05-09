!MNH_LIC Copyright 1994-2021 CNRS, Meteo-France and Universite Paul Sabatier
!MNH_LIC This is part of the Meso-NH software governed by the CeCILL-C licence
!MNH_LIC version 1. See LICENSE, CeCILL-C_V1-en.txt and CeCILL-C_V1-fr.txt
!MNH_LIC for details. version 1.
!-----------------------------------------------------------------
MODULE MODE_ICE4_RAINFR_VERT
IMPLICIT NONE
CONTAINS
SUBROUTINE ICE4_RAINFR_VERT(D, ICED, PPRFR, PRR, PRS, PRG, PRH)
!!
!!**  PURPOSE
!!    -------
!!      Computes the rain fraction
!!
!!    AUTHOR
!!    ------
!!      S. Riette from the plitting of rain_ice source code (nov. 2014)
!!
!!    MODIFICATIONS
!!    -------------
!!
!  P. Wautelet 13/02/2019: bugfix: intent of PPRFR OUT->INOUT
!  S. Riette 21/9/23: collapse JI/JJ
!
!
!*      0. DECLARATIONS
!          ------------
!
USE YOMHOOK , ONLY : LHOOK, DR_HOOK, JPHOOK
USE MODD_DIMPHYEX, ONLY: DIMPHYEX_t
USE MODD_RAIN_ICE_DESCR_n, ONLY : RAIN_ICE_DESCR_t
!
IMPLICIT NONE
!
!*       0.1   Declarations of dummy arguments :
!
TYPE(DIMPHYEX_t),              INTENT(IN)    :: D
TYPE(RAIN_ICE_DESCR_t),        INTENT(IN)    :: ICED
REAL, DIMENSION(D%NIJT,D%NKT), INTENT(INOUT) :: PPRFR !Precipitation fraction
REAL, DIMENSION(D%NIJT,D%NKT), INTENT(IN)    :: PRR !Rain field
REAL, DIMENSION(D%NIJT,D%NKT), INTENT(IN)    :: PRS !Snow field
REAL, DIMENSION(D%NIJT,D%NKT), INTENT(IN)    :: PRG !Graupel field
REAL, DIMENSION(D%NIJT,D%NKT), OPTIONAL, INTENT(IN)    :: PRH !Hail field
!
INTEGER :: IKB, IKE, IKL, IIJB, IIJE
!*       0.2  declaration of local variables
!
REAL(KIND=JPHOOK) :: ZHOOK_HANDLE
INTEGER :: JIJ, JK
LOGICAL :: MASK
!
!-------------------------------------------------------------------------------
IF (LHOOK) CALL DR_HOOK('ICE4_RAINFR_VERT',0,ZHOOK_HANDLE)
!
IKB=D%NKB
IKE=D%NKE
IKL=D%NKL
IIJB=D%NIJB
IIJE=D%NIJE
!
!-------------------------------------------------------------------------------
!
!$acc kernels
PPRFR(IIJB:IIJE,IKE)=0.
!$acc end kernels
DO JK=IKE-IKL, IKB, -IKL
  IF(PRESENT(PRH)) THEN
!$acc kernels
!$acc loop independent
    DO JIJ = IIJB, IIJE
      MASK=PRR(JIJ,JK) .GT. ICED%XRTMIN(3) .OR. PRS(JIJ,JK) .GT. ICED%XRTMIN(5) &
      .OR. PRG(JIJ,JK) .GT. ICED%XRTMIN(6) .OR. PRH(JIJ,JK) .GT. ICED%XRTMIN(7)
      IF (MASK) THEN
        PPRFR(JIJ,JK)=MAX(PPRFR(JIJ,JK),PPRFR(JIJ,JK+IKL))
        IF (PPRFR(JIJ,JK)==0) THEN
          PPRFR(JIJ,JK)=1.
        END IF
      ELSE
        PPRFR(JIJ,JK)=0.
      END IF
    END DO
!$acc end kernels
  ELSE
!$acc kernels
!$acc loop independent
    DO JIJ = IIJB, IIJE
      MASK=PRR(JIJ,JK) .GT. ICED%XRTMIN(3) .OR. PRS(JIJ,JK) .GT. ICED%XRTMIN(5) &
      .OR. PRG(JIJ,JK) .GT. ICED%XRTMIN(6)
      IF (MASK) THEN
        PPRFR(JIJ,JK)=MAX(PPRFR(JIJ,JK),PPRFR(JIJ,JK+IKL))
        IF (PPRFR(JIJ,JK)==0) THEN
          PPRFR(JIJ,JK)=1.
        END IF
      ELSE
        PPRFR(JIJ,JK)=0.
      END IF
    END DO
!$acc end kernels
  END IF
END DO
!
IF (LHOOK) CALL DR_HOOK('ICE4_RAINFR_VERT',1,ZHOOK_HANDLE)
!
END SUBROUTINE ICE4_RAINFR_VERT
END MODULE MODE_ICE4_RAINFR_VERT
