import styled from "styled-components";
import {GridButton} from './GridButton'

export const SquareButton = styled(GridButton)`
    border: 1px solid ${props => props.theme.colors.border.light};
    backdrop-filter: blur(14px);
    /* Note: backdrop-filter has minimal browser support */

    border-radius: 9px;
`;