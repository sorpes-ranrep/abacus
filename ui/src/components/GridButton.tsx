import styled from "styled-components";

export interface GridButtonProps {
    column: number,
    row: number,
    onClick: () => void,
    width?: number,
    height?: number,
}

export const GridButton = styled.button<GridButtonProps>`
    grid-column-start: ${({column}) => column};
    grid-column-end: span ${({width}) => width || 1};
    grid-row-start: ${({row}) => row};
    grid-row-end: span ${({height}) => height || 1};

    width: 100%;
    aspect-ratio: 1/1;
    // object-fit: contain;
`;