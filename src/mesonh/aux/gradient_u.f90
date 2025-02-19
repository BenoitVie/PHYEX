!MNH_LIC Copyright 1994-2020 CNRS, Meteo-France and Universite Paul Sabatier
!MNH_LIC This is part of the Meso-NH software governed by the CeCILL-C licence
!MNH_LIC version 1. See LICENSE, CeCILL-C_V1-en.txt and CeCILL-C_V1-fr.txt
!MNH_LIC for details. version 1.
!-----------------------------------------------------------------
!     ######################
      MODULE MODI_GRADIENT_U
!     ######################
!
IMPLICIT NONE
INTERFACE
!
!     
FUNCTION GX_U_M(PA,PDXX,PDZZ,PDZX, KKA, KKU, KL)      RESULT(PGX_U_M)
IMPLICIT NONE
INTEGER,              INTENT(IN),OPTIONAL     :: KKA, KKU ! near ground and uppest atmosphere array indexes
INTEGER,              INTENT(IN),OPTIONAL     :: KL     ! +1 if grid goes from ground to atmosphere top, -1 otherwise
REAL, DIMENSION(:,:,:),  INTENT(IN)  :: PA      ! variable at the U point
REAL, DIMENSION(:,:,:),  INTENT(IN)  :: PDXX    ! metric coefficient dxx
REAL, DIMENSION(:,:,:),  INTENT(IN)  :: PDZZ    ! metric coefficient dzz
REAL, DIMENSION(:,:,:),  INTENT(IN)  :: PDZX    ! metric coefficient dzx
!
REAL, DIMENSION(SIZE(PA,1),SIZE(PA,2),SIZE(PA,3)) :: PGX_U_M ! result mass point
!
END FUNCTION GX_U_M
!
!     
SUBROUTINE GX_U_M_DEVICE(PA,PDXX,PDZZ,PDZX,PGX_U_M_DEVICE)
REAL, DIMENSION(:,:,:), INTENT(IN) :: PA       ! variable at the U point
REAL, DIMENSION(:,:,:), INTENT(IN) :: PDXX     ! metric coefficient dxx
REAL, DIMENSION(:,:,:), INTENT(IN) :: PDZZ     ! metric coefficient dzz
REAL, DIMENSION(:,:,:), INTENT(IN) :: PDZX     ! metric coefficient dzx
!
REAL, DIMENSION(:,:,:), INTENT(OUT) :: PGX_U_M_DEVICE ! result mass point
!
END SUBROUTINE GX_U_M_DEVICE
!
FUNCTION GY_U_UV(PA,PDYY,PDZZ,PDZY, KKA, KKU, KL)      RESULT(PGY_U_UV)
IMPLICIT NONE
!
INTEGER,              INTENT(IN),OPTIONAL     :: KKA, KKU ! near ground and uppest atmosphere array indexes
INTEGER,              INTENT(IN),OPTIONAL     :: KL     ! +1 if grid goes from ground to atmosphere top, -1 otherwise
REAL, DIMENSION(:,:,:),  INTENT(IN)  :: PA      ! variable at the U point
REAL, DIMENSION(:,:,:),  INTENT(IN)  :: PDYY    ! metric coefficient dyy
REAL, DIMENSION(:,:,:),  INTENT(IN)  :: PDZZ    ! metric coefficient dzz
REAL, DIMENSION(:,:,:),  INTENT(IN)  :: PDZY    ! metric coefficient dzy
!
REAL, DIMENSION(SIZE(PA,1),SIZE(PA,2),SIZE(PA,3)) :: PGY_U_UV ! result UV point
!
END FUNCTION GY_U_UV
!
!
!
SUBROUTINE GY_U_UV_DEVICE(PA,PDYY,PDZZ,PDZY,PGY_U_UV_DEVICE)
REAL, DIMENSION(:,:,:), INTENT(IN) :: PA       ! variable at the U point
REAL, DIMENSION(:,:,:), INTENT(IN) :: PDYY     ! metric coefficient dyy
REAL, DIMENSION(:,:,:), INTENT(IN) :: PDZZ     ! metric coefficient dzz
REAL, DIMENSION(:,:,:), INTENT(IN) :: PDZY     ! metric coefficient dzy
!
REAL, DIMENSION(:,:,:), INTENT(OUT) :: PGY_U_UV_DEVICE ! result UV point
!
END SUBROUTINE GY_U_UV_DEVICE
!
FUNCTION GZ_U_UW(PA,PDZZ, KKA, KKU, KL)      RESULT(PGZ_U_UW)
IMPLICIT NONE
!
INTEGER,              INTENT(IN),OPTIONAL     :: KKA, KKU ! near ground and uppest atmosphere array indexes
INTEGER,              INTENT(IN),OPTIONAL     :: KL     ! +1 if grid goes from ground to atmosphere top, -1 otherwise
REAL, DIMENSION(:,:,:),  INTENT(IN)  :: PA      ! variable at the U point
REAL, DIMENSION(:,:,:),  INTENT(IN)  :: PDZZ    ! metric coefficient dzz
!
REAL, DIMENSION(SIZE(PA,1),SIZE(PA,2),SIZE(PA,3)) :: PGZ_U_UW ! result UW point
!
END FUNCTION GZ_U_UW
!
END INTERFACE
!
END MODULE MODI_GRADIENT_U
!
!
!
!
!     #######################################################
      FUNCTION GX_U_M(PA,PDXX,PDZZ,PDZX, KKA, KKU, KL)      RESULT(PGX_U_M)
!     #######################################################
!
!!****  *GX_U_M* - Cartesian Gradient operator: 
!!                          computes the gradient in the cartesian X
!!                          direction for a variable placed at the 
!!                          U point and the result is placed at
!!                          the mass point.
!!    PURPOSE
!!    -------
!       The purpose of this function is to compute the discrete gradient 
!     along the X cartesian direction for a field PA placed at the 
!     U point. The result is placed at the mass point.
!
!
!                       (          ______________z )
!                       (          (___________x ) )
!                    1  (          (d*zx dzm(PA) ) ) 
!      PGX_U_M =   ---- (dxf(PA) - (------------)) )
!                  ___x (          (             ) )
!                  d*xx (          (      d*zz   ) )     
!
!       
!
!!**  METHOD
!!    ------
!!      The Chain rule of differencing is applied to variables expressed
!!    in the Gal-Chen & Somerville coordinates to obtain the gradient in
!!    the cartesian system
!!        
!!    EXTERNAL
!!    --------
!!      MXF,MZF         : Shuman functions (mean operators)
!!      DXF,DZF         : Shuman functions (finite difference operators)
!!
!!    IMPLICIT ARGUMENTS
!!    ------------------
!!      NONE
!!
!!    REFERENCE
!!    ---------
!!      Book2 of documentation of Meso-NH (GRAD_CAR operators)
!!      A Turbulence scheme for the Meso-NH model (Chapter 6)
!!
!!    AUTHOR
!!    ------
!!      Joan Cuxart        *INM and Meteo-France*
!!
!!    MODIFICATIONS
!!    -------------
!!      Original    19/07/94
!!                  18/10/00 (V.Masson) add LFLAT switch
!-------------------------------------------------------------------------
!
!*       0.    DECLARATIONS
!
!
USE MODI_SHUMAN
USE MODD_CONF
!
IMPLICIT NONE
!
!
!*       0.1   declarations of arguments and result
!
INTEGER,                 INTENT(IN),OPTIONAL   :: KKA, KKU ! near ground and uppest atmosphere array indexes
INTEGER,                 INTENT(IN),OPTIONAL   :: KL     ! +1 if grid goes from ground to atmosphere top, -1 otherwise
REAL, DIMENSION(:,:,:),  INTENT(IN)  :: PA      ! variable at the U point
REAL, DIMENSION(:,:,:),  INTENT(IN)  :: PDXX    ! metric coefficient dxx
REAL, DIMENSION(:,:,:),  INTENT(IN)  :: PDZZ    ! metric coefficient dzz
REAL, DIMENSION(:,:,:),  INTENT(IN)  :: PDZX    ! metric coefficient dzx
!
REAL, DIMENSION(SIZE(PA,1),SIZE(PA,2),SIZE(PA,3)) :: PGX_U_M ! result mass point
!
!
!*       0.2   declaration of local variables
!
!              NONE
!
!----------------------------------------------------------------------------
!
!*       1.    DEFINITION of GX_U_M
!              --------------------
!
IF (.NOT. LFLAT) THEN
  PGX_U_M(:,:,:)= ( DXF(PA)        -                 &
                    MZF(MXF(PDZX*DZM(PA)) / PDZZ )  &
                  ) / MXF(PDXX)
ELSE
  PGX_U_M(:,:,:)= DXF(PA) /  MXF(PDXX)
END IF
!
!----------------------------------------------------------------------------
!
END FUNCTION GX_U_M
!
! 
#ifdef MNH_OPENACC
!     #######################################################
      SUBROUTINE GX_U_M_DEVICE(PA,PDXX,PDZZ,PDZX,PGX_U_M_DEVICE)
!     #######################################################
!
!*       0.    DECLARATIONS
!
!
USE MODI_SHUMAN_DEVICE
USE MODD_CONF
!
USE MODE_MNH_ZWORK, ONLY: MNH_MEM_GET, MNH_MEM_POSITION_PIN, MNH_MEM_RELEASE
!
IMPLICIT NONE
!
!
!*       0.1   declarations of arguments and result
!
REAL, DIMENSION(:,:,:), INTENT(IN) :: PA       ! variable at the U point
REAL, DIMENSION(:,:,:), INTENT(IN) :: PDXX     ! metric coefficient dxx
REAL, DIMENSION(:,:,:), INTENT(IN) :: PDZZ     ! metric coefficient dzz
REAL, DIMENSION(:,:,:), INTENT(IN) :: PDZX     ! metric coefficient dzx
!
REAL, DIMENSION(:,:,:), INTENT(OUT) :: PGX_U_M_DEVICE ! result mass point
!
!*       0.2   declaration of local variables
!
REAL, DIMENSION(:,:,:), pointer , contiguous ::  ZTMP1_DEVICE, ZTMP2_DEVICE, ZTMP3_DEVICE
!
INTEGER  :: JIU,JJU,JKU
INTEGER  :: JI,JJ,JK
!----------------------------------------------------------------------------

!$acc data present_crm( PA, PDXX, PDZZ, PDZX, PGX_U_M_DEVICE )

JIU =  size(pa, 1 )
JJU =  size(pa, 2 )
JKU =  size(pa, 3 )

!Pin positions in the pools of MNH memory
CALL MNH_MEM_POSITION_PIN( 'GX_U_M' )

CALL MNH_MEM_GET( ztmp1_device, JIU, JJU, JKU )
CALL MNH_MEM_GET( ztmp2_device, JIU, JJU, JKU )
CALL MNH_MEM_GET( ztmp3_device, JIU, JJU, JKU )

!$acc data present_crm( ztmp1_device, ztmp2_device, ztmp3_device )

!
!*       1.    DEFINITION of GX_U_M_DEVICE
!              --------------------
IF (.NOT. LFLAT) THEN
  CALL DXF_DEVICE(PA,ZTMP1_DEVICE)
  CALL DZM_DEVICE( PA, ZTMP2_DEVICE )
  !$acc kernels
   !$mnh_do_concurrent ( JI=1:JIU,JJ=1:JJU,JK=1:JKU)
     ZTMP3_DEVICE(JI,JJ,JK) = PDZX(JI,JJ,JK) * ZTMP2_DEVICE(JI,JJ,JK)
  !$mnh_end_do() !CONCURRENT
  !$acc end kernels
  CALL MXF_DEVICE(ZTMP3_DEVICE,ZTMP2_DEVICE)
  !$acc kernels
  !$mnh_do_concurrent ( JI=1:JIU,JJ=1:JJU,JK=1:JKU)
     ZTMP3_DEVICE(JI,JJ,JK) = ZTMP2_DEVICE(JI,JJ,JK) / PDZZ(JI,JJ,JK)
  !$mnh_end_do() !CONCURRENT
  !$acc end kernels
  CALL MZF_DEVICE( ZTMP3_DEVICE, ZTMP2_DEVICE )
  CALL MXF_DEVICE(PDXX,ZTMP3_DEVICE)
  !$acc kernels
  PGX_U_M_DEVICE(:,:,:)= ( ZTMP1_DEVICE(:,:,:) - ZTMP2_DEVICE(:,:,:) ) / ZTMP3_DEVICE(:,:,:)
  !$acc end kernels
ELSE
  CALL DXF_DEVICE(PA,ZTMP1_DEVICE)
  CALL MXF_DEVICE(PDXX,ZTMP2_DEVICE)
  !$acc kernels
  PGX_U_M_DEVICE(:,:,:)= ZTMP1_DEVICE(:,:,:) /  ZTMP2_DEVICE(:,:,:)
  !$acc end kernels
END IF

!$acc end data

!Release all memory allocated with MNH_MEM_GET calls since last call to MNH_MEM_POSITION_PIN
CALL MNH_MEM_RELEASE( 'GX_U_M' )

!$acc end data

!----------------------------------------------------------------------------
!
END SUBROUTINE GX_U_M_DEVICE
#endif
!
!
!     #########################################################
      FUNCTION GY_U_UV(PA,PDYY,PDZZ,PDZY, KKA, KKU, KL)      RESULT(PGY_U_UV)
!     #########################################################
!
!!****  *GY_U_UV* - Cartesian Gradient operator: 
!!                          computes the gradient in the cartesian Y
!!                          direction for a variable placed at the 
!!                          U point and the result is placed at
!!                          the UV vorticity point.
!!    PURPOSE
!!    -------
!       The purpose of this function is to compute the discrete gradient 
!     along the Y cartesian direction for a field PA placed at the 
!     U point. The result is placed at the UV vorticity point.
!
!
!
!                       (          _________________z )
!                       (          (___x _________y ) )
!                    1  (          (d*zy (dzm(PA))) ) )
!      PGY_U_UV=   ---- (dym(PA) - (     (------  ) ) )
!                  ___x (          (     ( ___x   ) ) )
!                  d*yy (          (     ( d*zz   ) ) )    
!
!       
!
!!**  METHOD
!!    ------
!!      The Chain rule of differencing is applied to variables expressed
!!    in the Gal-Chen & Somerville coordinates to obtain the gradient in
!!    the cartesian system
!!        
!!    EXTERNAL
!!    --------
!!      MXM,MYM,MZF     : Shuman functions (mean operators)
!!      DYM,DZM         : Shuman functions (finite difference operators)
!!
!!    IMPLICIT ARGUMENTS
!!    ------------------
!!      NONE
!!
!!    REFERENCE
!!    ---------
!!      Book2 of documentation of Meso-NH (GRAD_CAR operators)
!!      A Turbulence scheme for the Meso-NH model (Chapter 6)
!!
!!    AUTHOR
!!    ------
!!      Joan Cuxart        *INM and Meteo-France*
!!
!!    MODIFICATIONS
!!    -------------
!!      Original    20/07/94
!!                  18/10/00 (V.Masson) add LFLAT switch
!-------------------------------------------------------------------------
!
!*       0.    DECLARATIONS
!
!
USE MODI_SHUMAN
USE MODD_CONF
!
IMPLICIT NONE
!
!
!*       0.1   declarations of arguments and result
!
INTEGER,                 INTENT(IN),OPTIONAL   :: KKA, KKU ! near ground and uppest atmosphere array indexes
INTEGER,                 INTENT(IN),OPTIONAL   :: KL     ! +1 if grid goes from ground to atmosphere top, -1 otherwise
REAL, DIMENSION(:,:,:),  INTENT(IN)  :: PA      ! variable at the U point
REAL, DIMENSION(:,:,:),  INTENT(IN)  :: PDYY    ! metric coefficient dyy
REAL, DIMENSION(:,:,:),  INTENT(IN)  :: PDZZ    ! metric coefficient dzz
REAL, DIMENSION(:,:,:),  INTENT(IN)  :: PDZY    ! metric coefficient dzy
!
REAL, DIMENSION(SIZE(PA,1),SIZE(PA,2),SIZE(PA,3)) :: PGY_U_UV ! result UV point
!
!
!*       0.2   declaration of local variables
!
!              NONE
!
!----------------------------------------------------------------------------
!
!*       1.    DEFINITION of GY_U_UV
!              ---------------------
!
IF (.NOT. LFLAT) THEN
  PGY_U_UV(:,:,:)=  (DYM(PA)- MZF( MYM( DZM(PA)/&
                 MXM(PDZZ) ) *MXM(PDZY) )   ) / MXM(PDYY)
ELSE
  PGY_U_UV(:,:,:)= DYM(PA) / MXM(PDYY)
END IF
!
!----------------------------------------------------------------------------
!
END FUNCTION GY_U_UV
!
!
!     #########################################################
      SUBROUTINE GY_U_UV_DEVICE(PA,PDYY,PDZZ,PDZY,PGY_U_UV_DEVICE)
!     #########################################################
!
!*       0.    DECLARATIONS
!
!
USE MODI_SHUMAN_DEVICE
USE MODD_CONF
!
USE MODE_MNH_ZWORK, ONLY: MNH_MEM_GET, MNH_MEM_POSITION_PIN, MNH_MEM_RELEASE
!
IMPLICIT NONE
!
!
!*       0.1   declarations of arguments and result
!
REAL, DIMENSION(:,:,:), INTENT(IN) :: PA       ! variable at the U point
REAL, DIMENSION(:,:,:), INTENT(IN) :: PDYY     ! metric coefficient dyy
REAL, DIMENSION(:,:,:), INTENT(IN) :: PDZZ     ! metric coefficient dzz
REAL, DIMENSION(:,:,:), INTENT(IN) :: PDZY     ! metric coefficient dzy
!
REAL, DIMENSION(:,:,:), INTENT(OUT) :: PGY_U_UV_DEVICE ! result UV point
!
!
!*       0.2   declaration of local variables
!
REAL, DIMENSION(:,:,:), pointer , contiguous :: ZTMP1_DEVICE, ZTMP2_DEVICE, ZTMP3_DEVICE
!
INTEGER  :: JIU,JJU,JKU
INTEGER  :: JI,JJ,JK
!
!----------------------------------------------------------------------------

!$acc data present_crm( PA, PDYY, PDZZ, PDZY, PGY_U_UV_DEVICE )

JIU =  size(pa, 1 )
JJU =  size(pa, 2 )
JKU =  size(pa, 3 )

!Pin positions in the pools of MNH memory
#ifdef MNH_OPENACC
CALL MNH_MEM_POSITION_PIN( 'GY_U_UV' )

CALL MNH_MEM_GET( ztmp1_device, JIU, JJU, JKU )
CALL MNH_MEM_GET( ztmp2_device, JIU, JJU, JKU )
CALL MNH_MEM_GET( ztmp3_device, JIU, JJU, JKU )
#else
ALLOCATE(ztmp1_device(JIU, JJU, JKU ))
ALLOCATE(ztmp2_device(JIU, JJU, JKU ))
ALLOCATE(ztmp3_device(JIU, JJU, JKU ))
#endif 
!$acc data present_crm( ztmp1_device, ztmp2_device, ztmp3_device )

!
!*       1.    DEFINITION of GY_U_UV_DEVICE
!              ---------------------
!
IF (.NOT. LFLAT) THEN
  CALL DZM_DEVICE( PA, ZTMP1_DEVICE )
  CALL MXM_DEVICE(PDZZ,ZTMP2_DEVICE)
  !$acc kernels
  !$mnh_do_concurrent ( JI=1:JIU,JJ=1:JJU,JK=1:JKU)
     ZTMP3_DEVICE(JI,JJ,JK) = ZTMP1_DEVICE(JI,JJ,JK)/ZTMP2_DEVICE(JI,JJ,JK)
  !$mnh_end_do() !CONCURRENT    
  !$acc end kernels
  CALL MYM_DEVICE(ZTMP3_DEVICE,ZTMP1_DEVICE)
  CALL MXM_DEVICE(PDZY,ZTMP2_DEVICE)
  !$acc kernels
  !$mnh_do_concurrent ( JI=1:JIU,JJ=1:JJU,JK=1:JKU)
     ZTMP3_DEVICE(JI,JJ,JK) = ZTMP1_DEVICE(JI,JJ,JK)*ZTMP2_DEVICE(JI,JJ,JK)
  !$mnh_end_do() !CONCURRENT   
  !$acc end kernels
  CALL MZF_DEVICE( ZTMP3_DEVICE, ZTMP2_DEVICE )
  CALL DYM_DEVICE(PA,ZTMP1_DEVICE)
  CALL MXM_DEVICE(PDYY,ZTMP3_DEVICE)
  !$acc kernels
  !$mnh_do_concurrent ( JI=1:JIU,JJ=1:JJU,JK=1:JKU)
     PGY_U_UV_DEVICE(JI,JJ,JK)=  ( ZTMP1_DEVICE(JI,JJ,JK) - ZTMP2_DEVICE(JI,JJ,JK) ) / ZTMP3_DEVICE(JI,JJ,JK)
  !$mnh_end_do() !CONCURRENT   
  !$acc end kernels
ELSE
  CALL DYM_DEVICE(PA,ZTMP1_DEVICE)
  CALL MXM_DEVICE(PDYY,ZTMP2_DEVICE)
  !$acc kernels
  PGY_U_UV_DEVICE(:,:,:)= ZTMP1_DEVICE(:,:,:) / ZTMP2_DEVICE(:,:,:)
  !$acc end kernels
END IF

!$acc end data

!Release all memory allocated with MNH_MEM_GET calls since last call to MNH_MEM_POSITION_PIN
#ifdef MNH_OPENACC
CALL MNH_MEM_RELEASE( 'GY_U_UV' )
#else
DEALLOCATE(ZTMP1_DEVICE, ZTMP2_DEVICE, ZTMP3_DEVICE)
#endif
!$acc end data

!----------------------------------------------------------------------------
!
END SUBROUTINE GY_U_UV_DEVICE
!
!
!     #######################################################
      FUNCTION GZ_U_UW(PA,PDZZ, KKA, KKU, KL)      RESULT(PGZ_U_UW)
!     #######################################################
!
!!****  *GZ_U_UW - Cartesian Gradient operator: 
!!                          computes the gradient in the cartesian Z
!!                          direction for a variable placed at the 
!!                          U point and the result is placed at
!!                          the UW vorticity point.
!!    PURPOSE
!!    -------
!       The purpose of this function is to compute the discrete gradient 
!     along the Z cartesian direction for a field PA placed at the 
!     U point. The result is placed at the UW vorticity point.
!
!                   dzm(PA) 
!      PGZ_U_UW =   ------  
!                    ____x
!                    d*zz   
!
!!**  METHOD
!!    ------
!!      The Chain rule of differencing is applied to variables expressed
!!    in the Gal-Chen & Somerville coordinates to obtain the gradient in
!!    the cartesian system
!!        
!!    EXTERNAL
!!    --------
!!      MXM     : Shuman functions (mean operators)
!!      DZM     : Shuman functions (finite difference operators)
!!
!!    IMPLICIT ARGUMENTS
!!    ------------------
!!      NONE
!!
!!    REFERENCE
!!    ---------
!!      Book2 of documentation of Meso-NH (GRAD_CAR operators)
!!      A Turbulence scheme for the Meso-NH model (Chapter 6)
!!
!!    AUTHOR
!!    ------
!!      Joan Cuxart        *INM and Meteo-France*
!!
!!    MODIFICATIONS
!!    -------------
!!      Original    20/07/94
!-------------------------------------------------------------------------
!
!*       0.    DECLARATIONS
!
!
USE MODI_SHUMAN
!
IMPLICIT NONE
!
!
!*       0.1   declarations of arguments and result
!
INTEGER,              INTENT(IN),OPTIONAL      :: KKA, KKU ! near ground and uppest atmosphere array indexes
INTEGER,              INTENT(IN),OPTIONAL      :: KL     ! +1 if grid goes from ground to atmosphere top, -1 otherwise
REAL, DIMENSION(:,:,:),  INTENT(IN)  :: PA      ! variable at the U point
REAL, DIMENSION(:,:,:),  INTENT(IN)  :: PDZZ    ! metric coefficient dzz
!
REAL, DIMENSION(SIZE(PA,1),SIZE(PA,2),SIZE(PA,3)) :: PGZ_U_UW ! result UW point
!
!
!*       0.2   declaration of local variables
!
!              NONE
!
!----------------------------------------------------------------------------
!
!*       1.    DEFINITION of GZ_U_UW
!              ---------------------
!
PGZ_U_UW(:,:,:)= DZM(PA) / MXM(PDZZ)
!
!----------------------------------------------------------------------------
!
END FUNCTION GZ_U_UW
